import 'package:hive_ce/hive.dart';
// Import all model classes used in persistence
import 'package:komodo_coin_updates/src/models/address_format.dart';
import 'package:komodo_coin_updates/src/models/checkpoint_block.dart';
import 'package:komodo_coin_updates/src/models/coin.dart';
import 'package:komodo_coin_updates/src/models/coin_config.dart';
import 'package:komodo_coin_updates/src/models/coin_info.dart';
import 'package:komodo_coin_updates/src/models/consensus_params.dart';
import 'package:komodo_coin_updates/src/models/contact.dart';
import 'package:komodo_coin_updates/src/models/electrum.dart';
import 'package:komodo_coin_updates/src/models/links.dart';
import 'package:komodo_coin_updates/src/models/node.dart';
import 'package:komodo_coin_updates/src/models/protocol.dart';
import 'package:komodo_coin_updates/src/models/protocol_data.dart';
import 'package:komodo_coin_updates/src/models/rpc_url.dart';

@GenerateAdapters(<AdapterSpec<dynamic>>[
  AdapterSpec<Coin>(),
  AdapterSpec<Protocol>(),
  AdapterSpec<ProtocolData>(),
  AdapterSpec<AddressFormat>(),
  AdapterSpec<Links>(),
  AdapterSpec<ConsensusParams>(),
  AdapterSpec<CheckPointBlock>(),
  AdapterSpec<CoinConfig>(),
  AdapterSpec<Electrum>(),
  AdapterSpec<Node>(),
  AdapterSpec<Contact>(),
  AdapterSpec<RpcUrl>(),
  AdapterSpec<CoinInfo>(),
])
part 'hive_adapters.g.dart';
