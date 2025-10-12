/// Test fixtures for Cosmos chain data based on chains.cosmos.directory API
///
/// These fixtures contain real data snippets from the API to ensure
/// our models correctly parse the actual API response format.
class CosmosChainFixtures {
  /// Sample Cosmos Hub chain data from the actual API
  static final Map<String, dynamic> cosmosHubChain = {
    'name': 'cosmoshub',
    'path': 'cosmoshub',
    'chain_name': 'cosmoshub',
    'network_type': 'mainnet',
    'pretty_name': 'Cosmos Hub',
    'chain_id': 'cosmoshub-4',
    'status': 'live',
    'bech32_prefix': 'cosmos',
    'slip44': 118,
    'symbol': 'ATOM',
    'display': 'atom',
    'denom': 'uatom',
    'decimals': 6,
    'image':
        'https://raw.githubusercontent.com/cosmos/chain-registry/master/cosmoshub/images/atom.svg',
    'website': 'https://cosmos.network',
    'height': 23704830,
    'best_apis': {
      'rest': [
        {
          'address': 'https://cosmos-rest.publicnode.com',
          'provider': 'AllNodes ⚡️ Nodes & Staking',
        },
      ],
      'rpc': [
        {
          'address': 'https://cosmos-rpc.publicnode.com',
          'provider': 'AllNodes ⚡️ Nodes & Staking',
        },
      ],
    },
    'proxy_status': {'rest': true, 'rpc': true},
    'versions': {
      'application_version': 'v21.0.0',
      'cosmos_sdk_version': 'v0.50.10',
      'tendermint_version': '0.38.12',
    },
    'explorers': [
      {
        'kind': 'Chainroot',
        'url': 'https://explorer.chainroot.io/cosmoshub',
        'tx_page':
            'https://explorer.chainroot.io/cosmoshub/transactions/\${txHash}',
        'account_page':
            'https://explorer.chainroot.io/cosmoshub/accounts/\${accountAddress}',
      },
      {
        'kind': 'mintscan',
        'url': 'https://www.mintscan.io/cosmos',
        'tx_page': 'https://www.mintscan.io/cosmos/transactions/\${txHash}',
        'account_page':
            'https://www.mintscan.io/cosmos/accounts/\${accountAddress}',
      },
    ],
    'assets': [
      {
        'name': 'Cosmos Hub Atom',
        'description': 'The native staking token of the Cosmos Hub.',
        'symbol': 'ATOM',
        'denom': 'uatom',
        'decimals': 6,
        'base': {'denom': 'uatom', 'exponent': 0},
        'display': {'denom': 'atom', 'exponent': 6},
        'denom_units': [
          {'denom': 'uatom', 'exponent': 0},
          {'denom': 'atom', 'exponent': 6},
        ],
        'logo_URIs': {
          'png':
              'https://raw.githubusercontent.com/cosmos/chain-registry/master/cosmoshub/images/atom.png',
          'svg':
              'https://raw.githubusercontent.com/cosmos/chain-registry/master/cosmoshub/images/atom.svg',
        },
        'image':
            'https://raw.githubusercontent.com/cosmos/chain-registry/master/cosmoshub/images/atom.svg',
      },
    ],
    'coingecko_id': 'cosmos',
  };

  /// Sample Osmosis chain data
  static final Map<String, dynamic> osmosisChain = {
    'name': 'osmosis',
    'path': 'osmosis',
    'chain_name': 'osmosis',
    'network_type': 'mainnet',
    'pretty_name': 'Osmosis',
    'chain_id': 'osmosis-1',
    'status': 'live',
    'bech32_prefix': 'osmo',
    'slip44': 118,
    'symbol': 'OSMO',
    'display': 'osmo',
    'denom': 'uosmo',
    'decimals': 6,
    'image':
        'https://raw.githubusercontent.com/cosmos/chain-registry/master/osmosis/images/osmo.svg',
    'website': 'https://osmosis.zone',
    'height': 22017642,
    'best_apis': {
      'rest': [
        {'address': 'https://osmosis-api.polkachu.com', 'provider': 'Polkachu'},
      ],
      'rpc': [
        {'address': 'https://osmosis-rpc.polkachu.com', 'provider': 'Polkachu'},
      ],
    },
    'proxy_status': {'rest': true, 'rpc': true},
    'versions': {
      'application_version': 'v28.0.0',
      'cosmos_sdk_version': 'v0.50.10',
      'tendermint_version': '0.38.12',
    },
    'explorers': [
      {
        'kind': 'mintscan',
        'url': 'https://www.mintscan.io/osmosis',
        'tx_page': 'https://www.mintscan.io/osmosis/transactions/\${txHash}',
      },
    ],
    'assets': [
      {
        'name': 'Osmosis',
        'description': 'The native token of Osmosis',
        'symbol': 'OSMO',
        'denom': 'uosmo',
        'decimals': 6,
        'base': {'denom': 'uosmo', 'exponent': 0},
        'display': {'denom': 'osmo', 'exponent': 6},
        'denom_units': [
          {'denom': 'uosmo', 'exponent': 0},
          {'denom': 'osmo', 'exponent': 6},
        ],
      },
    ],
  };

  /// Sample Akash chain data
  static final Map<String, dynamic> akashChain = {
    'name': 'akash',
    'path': 'akash',
    'chain_name': 'akash',
    'network_type': 'mainnet',
    'pretty_name': 'Akash',
    'chain_id': 'akashnet-2',
    'status': 'live',
    'bech32_prefix': 'akash',
    'slip44': 118,
    'symbol': 'AKT',
    'display': 'akt',
    'denom': 'uakt',
    'decimals': 6,
    'coingecko_id': 'akash-network',
    'image':
        'https://raw.githubusercontent.com/cosmos/chain-registry/master/akash/images/akt.svg',
    'website': 'https://akash.network/',
    'height': 23704830,
    'best_apis': {
      'rest': [
        {
          'address': 'https://akash-mainnet-rest.cosmonautstakes.com/',
          'provider': 'Cosmonaut Stakes',
        },
      ],
      'rpc': [
        {
          'address': 'https://akash-mainnet-rpc.cosmonautstakes.com/',
          'provider': 'Cosmonaut Stakes',
        },
      ],
    },
    'proxy_status': {'rest': true, 'rpc': true},
    'versions': {
      'application_version': 'v0.38.0',
      'cosmos_sdk_version': 'v0.45.16',
      'tendermint_version': '0.34.27',
    },
    'explorers': [
      {
        'kind': 'mintscan',
        'url': 'https://www.mintscan.io/akash',
        'tx_page': 'https://www.mintscan.io/akash/transactions/\${txHash}',
        'account_page':
            'https://www.mintscan.io/akash/accounts/\${accountAddress}',
      },
    ],
    'assets': [
      {
        'name': 'Akash Network',
        'description':
            'Akash Network is a decentralized cloud computing marketplace that connects users with unused computing resources, offering a cost-effective alternative to traditional cloud providers.',
        'symbol': 'AKT',
        'denom': 'uakt',
        'decimals': 6,
        'coingecko_id': 'akash-network',
        'base': {'denom': 'uakt', 'exponent': 0},
        'display': {'denom': 'akt', 'exponent': 6},
        'denom_units': [
          {'denom': 'uakt', 'exponent': 0},
          {'denom': 'akt', 'exponent': 6},
        ],
      },
    ],
  };

  /// Complete API response structure sample
  static final Map<String, dynamic> fullApiResponse = {
    'repository': {
      'url': 'https://github.com/cosmos/chain-registry',
      'branch': 'master',
      'commit': '1e336d5970d970964a6644c498737ad64771784c',
      'timestamp': 1760120355,
    },
    'chains': [cosmosHubChain, osmosisChain, akashChain],
  };

  /// Minimal chain data for testing edge cases
  static final Map<String, dynamic> minimalChain = {
    'name': 'testchain',
    'path': 'testchain',
    'chain_name': 'testchain',
    'network_type': 'mainnet',
    'pretty_name': 'Test Chain',
    'chain_id': 'test-1',
    'status': 'live',
    'bech32_prefix': 'test',
    'slip44': 118,
    'symbol': 'TEST',
    'display': 'test',
    'denom': 'utest',
    'decimals': 6,
    'height': null,
    'best_apis': {
      'rest': <Map<String, dynamic>>[],
      'rpc': <Map<String, dynamic>>[],
    },
    'proxy_status': {'rest': false, 'rpc': false},
    'versions': <String, dynamic>{},
    'explorers': <Map<String, dynamic>>[],
    'assets': <Map<String, dynamic>>[],
  };
}
