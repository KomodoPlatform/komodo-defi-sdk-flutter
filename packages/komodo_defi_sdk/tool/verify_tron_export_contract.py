#!/usr/bin/env python3
"""Opt-in exact-pin KDF regression: public fixture, loopback node, no broadcast.

Run: python3 tool/verify_tron_export_contract.py --binary /absolute/path/to/kdf
The binary must report f3efd2c. No key or raw RPC response is printed. All wallet
files and KDF logs live in a TemporaryDirectory and are removed on completion.
P2P is in-memory; every configured TRON node is loopback. Unknown node requests
fail and are checked at the end. This checks the backend contract underlying the
SDK's deliberately limited current-activated-address export, including index 7.
"""
import argparse
import http.server
import json
import os
import pathlib
import socket
import subprocess
import tempfile
import threading
import time
import urllib.error
import urllib.request

FIXTURE = " ".join(["abandon"] * 11 + ["about"])
RPC_PASSWORD = "Synthetic-Export-Test-4829#Public"
TOKEN = "USDT-TRC20"


def require(condition, label):
    if not condition:
        raise AssertionError(label)


def free_port():
    with socket.socket() as sock:
        sock.bind(("127.0.0.1", 0))
        return sock.getsockname()[1]


class Node(http.server.BaseHTTPRequestHandler):
    def log_message(self, *_):
        pass

    def do_POST(self):
        body = json.loads(self.rfile.read(int(self.headers.get("Content-Length", 0))))
        self.server.paths.add(self.path)
        if self.path == "/wallet/getnowblock":
            response = {"blockID": "00" * 32, "block_header": {"raw_data": {
                "number": 1, "timestamp": int(time.time() * 1000)}}}
        elif self.path == "/wallet/getaccount":
            response = {}
        elif self.path == "/wallet/triggerconstantcontract":
            response = {"result": {"result": True}, "constant_result": [
                format(6 if body.get("function_selector") == "decimals()" else 0, "064x")]}
        else:
            self.server.unexpected.add(self.path)
            self.send_error(400)
            return
        encoded = json.dumps(response).encode()
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(encoded)))
        self.end_headers()
        self.wfile.write(encoded)


def rpc(port, method, params=None, legacy=False):
    payload = {"userpass": RPC_PASSWORD, "method": method}
    if legacy:
        payload.update(params or {})
    else:
        payload.update({"mmrpc": "2.0", "params": params or {}})
    request = urllib.request.Request(
        f"http://127.0.0.1:{port}", json.dumps(payload).encode(),
        {"Content-Type": "application/json"}, method="POST")
    # Explicitly ignore proxy environment variables, even for loopback.
    opener = urllib.request.build_opener(urllib.request.ProxyHandler({}))
    try:
        with opener.open(request, timeout=15) as response:
            return response.status, json.load(response)
    except urllib.error.HTTPError as error:
        return error.code, json.load(error)


def check_index(binary, index, node):
    port = free_port()
    coins = [
        {"coin": "TRX", "mm2": 1, "wallet_only": True, "decimals": 6,
         "protocol": {"type": "TRX", "protocol_data": {"network": "Mainnet"}},
         "derivation_path": "m/44'/195'"},
        {"coin": TOKEN, "mm2": 1, "wallet_only": True, "decimals": 6,
         "protocol": {"type": "TRC20", "protocol_data": {"platform": "TRX",
             "contract_address": "TNPeeaaFB7K9cmo4uQpcU32zGK8G1NYqeL"}},
         "derivation_path": "m/44'/195'"},
        # Synthetic reference ONLY: proves selection of the same secp256k1
        # derivation. Production must never treat TRON as an ETH asset.
        {"coin": "ETH_REFERENCE", "mm2": 1, "wallet_only": True, "decimals": 18,
         "protocol": {"type": "ETH", "protocol_data": {"chain_id": 1}},
         "derivation_path": "m/44'/195'"},
    ]
    with tempfile.TemporaryDirectory(prefix="kdf-tron-export-fixture-") as folder:
        root = pathlib.Path(folder)
        config = {
            "gui": "synthetic-export-contract", "netid": 6133,
            "rpcip": "127.0.0.1", "rpcport": port, "rpc_local_only": True,
            "rpc_password": RPC_PASSWORD, "enable_hd": True, "passphrase": FIXTURE,
            "dbdir": str(root / "db"), "coins": coins,
            "p2p_in_memory": True, "p2p_in_memory_port": 123456 + index,
            "i_am_seed": True, "is_bootstrap_node": True, "seednodes": [],
        }
        (root / "MM2.json").write_text(json.dumps(config))
        (root / "coins").write_text("[]")
        env = dict(os.environ, MM_CONF_PATH=str(root / "MM2.json"),
                   MM_COINS_PATH=str(root / "coins"), MM_LOG=str(root / "kdf.log"))
        with (root / "process.log").open("wb") as output:
            process = subprocess.Popen([str(binary)], cwd=root, env=env,
                                       stdout=output, stderr=output)
            try:
                for _ in range(120):
                    if process.poll() is not None:
                        raise AssertionError("Synthetic KDF exited during startup")
                    try:
                        status, _ = rpc(port, "version", legacy=True)
                        if status == 200:
                            break
                    except (OSError, ValueError):
                        time.sleep(0.1)
                else:
                    raise AssertionError("Synthetic KDF startup timed out")
                status, activation = rpc(port, "enable_eth_with_tokens", {
                    "ticker": "TRX", "mm2": 1,
                    "nodes": [{"url": f"http://127.0.0.1:{node.server_port}"}],
                    "erc20_tokens_requests": [{"ticker": TOKEN}],
                    "get_balances": False, "scan_policy": "do_not_scan",
                    "min_addresses_number": index + 1,
                    "path_to_address": {"account_id": 0, "chain": "External", "address_id": index},
                })
                require(status == 200 and "result" in activation, "TRON fixture activation failed")
                status, offline = rpc(port, "get_private_keys", {
                    "coins": ["ETH_REFERENCE"], "mode": "hd", "start_index": 0, "end_index": 7})
                require(status == 200, "Synthetic reference derivation failed")
                reference = offline["result"][0]["addresses"]
                selected = reference[index]["priv_key"].removeprefix("0x")
                other = reference[7 if index == 0 else 0]["priv_key"].removeprefix("0x")
                keys = []
                for ticker in ["TRX", TOKEN]:
                    status, shown = rpc(port, "show_priv_key", {"coin": ticker}, legacy=True)
                    require(status == 200 and shown.get("result", {}).get("coin") == ticker, "Online key contract changed")
                    key = shown["result"]["priv_key"].removeprefix("0x")
                    require(key == selected and key != other, "Online key does not match activated index")
                    keys.append(key)
                    status, ignored = rpc(port, "show_priv_key", {"coin": ticker,
                        "path_to_address": {"account_id": 0, "chain": "External", "address_id": 7 if index == 0 else 0}}, legacy=True)
                    require(status == 200 and ignored["result"]["priv_key"] == shown["result"]["priv_key"],
                            "Legacy endpoint path behavior changed")
                require(keys[0] == keys[1], "TRC20 no longer inherits platform signing key")
                status, balance = rpc(port, "account_balance", {"coin": "TRX", "account_index": 0,
                    "chain": "External", "limit": 100, "paging_options": {"PageNumber": 1}})
                require(status == 200, "Fresh direct account_balance unsupported")
                addresses = balance["result"]["addresses"]
                expected_path = f"m/44'/195'/0'/0/{index}"
                candidates = [entry for entry in addresses if entry["derivation_path"] == expected_path]
                require(len(candidates) == 1 and candidates[0]["address"].startswith("T"),
                        "Fresh metadata missing selected owner address/path")
                require(candidates[0]["chain"] == "External", "Fresh metadata chain mismatch")
                status, _ = rpc(port, "my_balance", {"coin": "TRX"}, legacy=True)
                require(status != 200, "HD my_balance contract changed; revisit export metadata")
                status, _ = rpc(port, "get_private_keys", {"coins": ["TRX"], "mode": "hd"})
                require(status != 200, "TRON offline support changed; revisit limited export")
                print(f"PASS: pinned KDF, active index {index}, token inheritance, ignored path, fresh metadata")
            finally:
                process.terminate()
                try:
                    process.wait(timeout=5)
                except subprocess.TimeoutExpired:
                    process.kill()
                    process.wait(timeout=5)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--binary", type=pathlib.Path, required=True)
    args = parser.parse_args()
    binary = args.binary.resolve(strict=True)
    version = subprocess.run([str(binary), "--version"], capture_output=True, text=True, timeout=10)
    require("f3efd2c" in version.stdout + version.stderr, "Requires the reviewed f3efd2c KDF binary")
    node = http.server.ThreadingHTTPServer(("127.0.0.1", 0), Node)
    node.paths, node.unexpected = set(), set()
    thread = threading.Thread(target=node.serve_forever, daemon=True)
    thread.start()
    try:
        for index in [0, 7]:
            check_index(binary, index, node)
        require(not node.unexpected, "Unexpected node endpoint requested")
        print("PASS: only loopback read endpoints used; temporary wallet data removed")
    finally:
        node.shutdown()
        node.server_close()
        thread.join(timeout=3)


if __name__ == "__main__":
    try:
        main()
    except (AssertionError, OSError, ValueError, KeyError, subprocess.SubprocessError) as error:
        # No raw response or private material in exception diagnostics.
        label = str(error) if isinstance(error, AssertionError) else type(error).__name__
        print(f"FAIL: synthetic contract verification ({label})")
        raise SystemExit(1) from None
