/// Test fixtures for EVM chain info based on real chainid.network API data.
class EvmChainFixtures {
  /// Ethereum Mainnet fixture from chainid.network API
  static const Map<String, dynamic> ethereumMainnet = {
    'name': 'Ethereum Mainnet',
    'chainId': 1,
    'shortName': 'eth',
    'networkId': 1,
    'nativeCurrency': {'name': 'Ether', 'symbol': 'ETH', 'decimals': 18},
    'rpc': [
      'https://mainnet.infura.io/v3/\${INFURA_API_KEY}',
      'wss://mainnet.infura.io/ws/v3/\${INFURA_API_KEY}',
      'https://api.mycryptoapi.com/eth',
      'https://cloudflare-eth.com',
      'https://ethereum-rpc.publicnode.com',
      'wss://ethereum-rpc.publicnode.com',
      'https://mainnet.gateway.tenderly.co',
      'wss://mainnet.gateway.tenderly.co',
      'https://rpc.blocknative.com/boost',
      'https://rpc.flashbots.net',
      'https://rpc.flashbots.net/fast',
      'https://rpc.mevblocker.io',
      'https://rpc.mevblocker.io/fast',
      'https://rpc.mevblocker.io/noreverts',
      'https://rpc.mevblocker.io/fullprivacy',
      'https://eth.drpc.org',
      'wss://eth.drpc.org',
      'https://api.securerpc.com/v1',
    ],
    'faucets': <String>[],
    'infoURL': 'https://ethereum.org',
  };

  /// BNB Smart Chain Mainnet fixture from chainid.network API
  static const Map<String, dynamic> bnbSmartChain = {
    'name': 'BNB Smart Chain Mainnet',
    'chainId': 56,
    'shortName': 'bnb',
    'networkId': 56,
    'nativeCurrency': {
      'name': 'BNB Chain Native Token',
      'symbol': 'BNB',
      'decimals': 18,
    },
    'rpc': [
      'https://bsc-dataseed1.bnbchain.org',
      'https://bsc-dataseed2.bnbchain.org',
      'https://bsc-dataseed3.bnbchain.org',
      'https://bsc-dataseed4.bnbchain.org',
      'https://bsc-dataseed1.defibit.io',
      'https://bsc-dataseed2.defibit.io',
      'https://bsc-dataseed3.defibit.io',
      'https://bsc-dataseed4.defibit.io',
      'https://bsc-dataseed1.ninicoin.io',
      'https://bsc-dataseed2.ninicoin.io',
      'https://bsc-dataseed3.ninicoin.io',
      'https://bsc-dataseed4.ninicoin.io',
      'https://bsc-rpc.publicnode.com',
      'wss://bsc-rpc.publicnode.com',
      'wss://bsc-ws-node.nariox.org',
    ],
    'faucets': <String>[],
    'infoURL': 'https://www.bnbchain.org/en',
  };

  /// Polygon Mainnet fixture from chainid.network API
  static const Map<String, dynamic> polygonMainnet = {
    'name': 'Polygon Mainnet',
    'chainId': 137,
    'shortName': 'matic',
    'networkId': 137,
    'nativeCurrency': {'name': 'MATIC', 'symbol': 'MATIC', 'decimals': 18},
    'rpc': [
      'https://polygon-rpc.com',
      'https://rpc-mainnet.matic.network',
      'https://matic-mainnet.chainstacklabs.com',
      'https://rpc-mainnet.maticvigil.com',
      'https://rpc-mainnet.matic.quiknode.pro',
      'https://matic-mainnet-full-rpc.bwarelabs.com',
    ],
    'faucets': <String>[],
    'infoURL': 'https://polygon.technology/',
  };

  /// Goerli Testnet fixture from chainid.network API
  static const Map<String, dynamic> goerliTestnet = {
    'name': 'Goerli',
    'chainId': 5,
    'shortName': 'gor',
    'networkId': 5,
    'nativeCurrency': {'name': 'Goerli Ether', 'symbol': 'ETH', 'decimals': 18},
    'rpc': [
      'https://goerli.infura.io/v3/\${INFURA_API_KEY}',
      'wss://goerli.infura.io/v3/\${INFURA_API_KEY}',
      'https://rpc.goerli.mudit.blog/',
      'https://ethereum-goerli-rpc.publicnode.com',
      'wss://ethereum-goerli-rpc.publicnode.com',
      'https://goerli.gateway.tenderly.co',
      'wss://goerli.gateway.tenderly.co',
    ],
    'faucets': [
      'http://fauceth.komputing.org?chain=5&address=\${ADDRESS}',
      'https://goerli-faucet.slock.it?address=\${ADDRESS}',
      'https://faucet.goerli.mudit.blog',
    ],
    'infoURL': 'https://goerli.net/#about',
  };

  /// BNB Smart Chain Testnet fixture from chainid.network API
  static const Map<String, dynamic> bnbTestnet = {
    'name': 'BNB Smart Chain Testnet',
    'chainId': 97,
    'shortName': 'bnbt',
    'networkId': 97,
    'nativeCurrency': {
      'name': 'BNB Chain Native Token',
      'symbol': 'tBNB',
      'decimals': 18,
    },
    'rpc': [
      'https://data-seed-prebsc-1-s1.bnbchain.org:8545',
      'https://data-seed-prebsc-2-s1.bnbchain.org:8545',
      'https://data-seed-prebsc-1-s2.bnbchain.org:8545',
      'https://data-seed-prebsc-2-s2.bnbchain.org:8545',
      'https://data-seed-prebsc-1-s3.bnbchain.org:8545',
      'https://data-seed-prebsc-2-s3.bnbchain.org:8545',
      'https://bsc-testnet-rpc.publicnode.com',
      'wss://bsc-testnet-rpc.publicnode.com',
    ],
    'faucets': ['https://testnet.bnbchain.org/faucet-smart'],
    'infoURL': 'https://www.bnbchain.org/en',
  };

  /// Minimal chain fixture for testing edge cases
  static const Map<String, dynamic> minimalChain = {
    'name': 'Test Chain',
    'chainId': 999,
    'shortName': 'test',
    'networkId': 999,
    'nativeCurrency': {'name': 'Test Token', 'symbol': 'TEST', 'decimals': 18},
    'rpc': <String>[],
    'faucets': <String>[],
    'infoURL': '',
  };
}
