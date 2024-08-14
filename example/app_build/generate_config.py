# TODO: Move this to the CLI utility package?

# See the (docs)[https://komodoplatform.com/en/docs/smart-chains/setup/common-runtime-parameters/]
# for more information on the runtime parameters.

import json
import os
import random
import re
import requests


class StartupConfigManager:
    coins_url = "https://komodoplatform.github.io/coins/coins"

    def generate_start_params_from_default(self, seed, userpass=None):
        user_home = os.path.expanduser("~") + "/kdf/test_remote"
        db_dir = user_home

        for dir in [user_home, db_dir]:
            # Warn if the directory doesn't already exist and ask if we should create it
            if not os.path.exists(dir):
                print(f"Directory '{dir}' does not exist. Should we create it? (y/n)")
                response = input().lower()
                if response == "y":
                    os.makedirs(user_home)
                else:
                    raise Exception("User home directory does not exist.")

        userpass = userpass or self.generate_password()

        params = self.generate_start_params(
            "GUI_FLUTTER",
            seed,
            user_home,
            db_dir,
            userpass=userpass,
        )

        # Ask the user which IP addresses to allow for remote access. Default is
        # localhost only. (provide the IP addresses separated by commas)
        default_ips = "127.0.0.1,localhost"
        print(
            f"Which IP addresses should be allowed for remote access? Default is {default_ips}. IPV6 and subnets can be specified."
        )
        response = input("IP address(es) (separated by commas): ") or default_ips
        # Each IP should be a separate entry in the map with "rpcallowip" as the key
        for ip in response.split(","):
            params["rpcallowip"] = ip
        print("IP addresses allowed for remote access: ", response)

        return params

    def generate_start_params(self, gui, passphrase, user_home, db_dir, userpass):
        coins_data = self.fetch_coins_data()

        if not coins_data:
            raise Exception("Failed to fetch coins data.")

        start_params = {
            "mm2": 1,
            "allow_weak_password": False,
            "rpc_password": userpass,
            "netid": 8762,
            "gui": gui,
            "userhome": user_home,
            "dbdir": db_dir,
            "passphrase": passphrase,
            "coins": json.loads(coins_data),
        }

        return start_params

    def fetch_coins_data(self):
        response = requests.get(self.coins_url)
        return response.text

    def generate_password(self):
        lower_case = "abcdefghijklmnopqrstuvwxyz"
        upper_case = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        digit = "0123456789"
        punctuation = "*.!@#%^():;',.?/~`_+-=|"
        string_sets = [lower_case, upper_case, digit, punctuation]

        rng = random.SystemRandom()
        length = rng.randint(8, 32)  # Password length between 8 and 32 characters

        password = [0] * length
        set_counts = [0] * 4

        for i in range(length):
            set_index = rng.randint(0, 3)
            set_counts[set_index] += 1
            password[i] = string_sets[set_index][
                rng.randint(0, len(string_sets[set_index]) - 1)
            ]

        for i in range(len(set_counts)):
            if set_counts[i] == 0:
                pos = rng.randint(0, length - 1)
                password[pos] = string_sets[i][rng.randint(0, len(string_sets[i]) - 1)]

        result = "".join(password)

        if not self.validate_rpc_password(result):
            return self.generate_password()

        return result

    def validate_rpc_password(self, src):
        if not src:
            return False

        if "password" in src.lower():
            return False

        exp = re.compile(
            r"^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[^A-Za-z0-9]).{8,32}$"
        )
        if not exp.match(src):
            return False

        for i in range(len(src) - 2):
            if src[i] == src[i + 1] and src[i + 1] == src[i + 2]:
                return False

        return True


def main():
    config_manager = StartupConfigManager()
    start_params = config_manager.generate_start_params_from_default(
        "change custom consider lottery zero city soft family brass afraid long finish"
    )

    # Ask if we should write the file to the db directory
    db_dir = start_params["dbdir"]
    print(f"Write the file to the db directory '{db_dir}/MM2.json'? (y/N)")
    response = input().lower()
    if response == "y":
        with open(f"{db_dir}/MM2.json", "w") as file:
            json.dump(start_params, file, indent=4)
    else:
        print("File not written to db directory.")

        current_directory_abs_path = path.resolve()
        # Ask the user where they would like to write the file (default is current directory)
        response = input(
            f"Where would you like to write the file? Default is current directory '{current_directory_abs_path}/MM2.json'"
        )
        if not response:
            response = current_directory_abs_path

        with open(f"{response}", "w") as file:
            json.dump(start_params, file, indent=4)

    print("File written successfully.")


# Run the main function
main()

# # Export the file for download
# import shutil

# shutil.move("MM2.json", "/mnt/data/MM2.json")
