import 'package:collection/collection.dart';
import 'package:komodo_defi_sdk/src/_internal_exports.dart' show IAssetLookup;
import 'package:komodo_defi_sdk/src/activation/asset_group.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:test/test.dart';

class MockAssetLookup implements IAssetLookup {
  MockAssetLookup(this._assets);
  final Map<AssetId, Asset> _assets;

  @override
  Map<AssetId, Asset> get available => _assets;

  @override
  Set<Asset> findAssetsByConfigId(String ticker) =>
      _assets.values.where((a) => a.id.id == ticker).toSet();

  @override
  Asset? fromId(AssetId id) => _assets[id];

  @override
  Set<Asset> childAssetsOf(AssetId parentId) =>
      _assets.values.where((a) => a.id.parentId == parentId).toSet();
}

AssetId makeAssetId({
  required String id,
  required String name,
  CoinSubClass subClass = CoinSubClass.bep20,
  AssetId? parentId,
}) {
  return AssetId(
    id: id,
    name: name,
    symbol: AssetSymbol(assetConfigId: id),
    chainId: AssetChainId(chainId: 1),
    derivationPath: null,
    subClass: subClass,
    parentId: parentId,
  );
}

class DummyProtocol extends ProtocolClass {
  const DummyProtocol({required super.subClass}) : super(config: const {});
  @override
  bool get supportsMultipleAddresses => false;
  @override
  bool get requiresHdWallet => false;
  @override
  bool get isMemoSupported => false;
}

Asset makeAsset({required AssetId id, CoinSubClass? protocolSubClass}) {
  return Asset(
    id: id,
    protocol: DummyProtocol(subClass: protocolSubClass ?? id.subClass),
    isWalletOnly: false,
    signMessagePrefix: null,
  );
}

void main() {
  group('AssetGroup.groupByPrimary', () {
    late AssetId bnbId;
    late AssetId usdtBep20Id;
    late AssetId cakeBep20Id;
    late AssetId ethId;
    late AssetId usdtErc20Id;
    late AssetId btcId;
    late AssetId ltcId;
    late AssetId dogeId;
    late AssetId kmdId;
    late AssetId maticId;
    late AssetId usdtMaticId;
    late AssetId usdcMaticId;
    late AssetId atomId;
    late AssetId osmoId;
    late AssetId osmoTokenId;
    late Asset bnb;
    late Asset usdtBep20;
    late Asset cakeBep20;
    late Asset eth;
    late Asset usdtErc20;
    late Asset btc;
    late Asset ltc;
    late Asset doge;
    late Asset kmd;
    late Asset matic;
    late Asset usdtMatic;
    late Asset usdcMatic;
    late Asset atom;
    late Asset osmo;
    late Asset osmoToken;
    late MockAssetLookup lookup;

    setUp(() {
      bnbId = makeAssetId(id: 'BNB', name: 'BNB');
      usdtBep20Id = makeAssetId(
        id: 'USDT-BEP20',
        name: 'USDT-BEP20',
        parentId: bnbId,
      );
      cakeBep20Id = makeAssetId(
        id: 'CAKE-BEP20',
        name: 'CAKE-BEP20',
        parentId: bnbId,
      );
      ethId = makeAssetId(id: 'ETH', name: 'ETH', subClass: CoinSubClass.erc20);
      usdtErc20Id = makeAssetId(
        id: 'USDT-ERC20',
        name: 'USDT-ERC20',
        subClass: CoinSubClass.erc20,
        parentId: ethId,
      );
      btcId = makeAssetId(id: 'BTC', name: 'BTC', subClass: CoinSubClass.utxo);
      ltcId = makeAssetId(id: 'LTC', name: 'LTC', subClass: CoinSubClass.utxo);
      dogeId = makeAssetId(
        id: 'DOGE',
        name: 'DOGE',
        subClass: CoinSubClass.utxo,
      );
      kmdId = makeAssetId(id: 'KMD', name: 'KMD', subClass: CoinSubClass.utxo);
      maticId = makeAssetId(
        id: 'MATIC',
        name: 'MATIC',
        subClass: CoinSubClass.matic,
      );
      usdtMaticId = makeAssetId(
        id: 'USDT-MATIC',
        name: 'USDT-MATIC',
        subClass: CoinSubClass.matic,
        parentId: maticId,
      );
      usdcMaticId = makeAssetId(
        id: 'USDC-MATIC',
        name: 'USDC-MATIC',
        subClass: CoinSubClass.matic,
        parentId: maticId,
      );
      atomId = makeAssetId(
        id: 'ATOM',
        name: 'ATOM',
        subClass: CoinSubClass.tendermint,
      );
      osmoId = makeAssetId(
        id: 'OSMO',
        name: 'OSMO',
        subClass: CoinSubClass.tendermint,
      );
      osmoTokenId = makeAssetId(
        id: 'OSMO-TOKEN',
        name: 'OSMO-TOKEN',
        subClass: CoinSubClass.tendermintToken,
        parentId: osmoId,
      );
      bnb = makeAsset(id: bnbId);
      usdtBep20 = makeAsset(id: usdtBep20Id);
      cakeBep20 = makeAsset(id: cakeBep20Id);
      eth = makeAsset(id: ethId);
      usdtErc20 = makeAsset(id: usdtErc20Id);
      btc = makeAsset(id: btcId);
      ltc = makeAsset(id: ltcId);
      doge = makeAsset(id: dogeId);
      kmd = makeAsset(id: kmdId);
      matic = makeAsset(id: maticId);
      usdtMatic = makeAsset(id: usdtMaticId);
      usdcMatic = makeAsset(id: usdcMaticId);
      atom = makeAsset(id: atomId);
      osmo = makeAsset(id: osmoId);
      osmoToken = makeAsset(id: osmoTokenId);
      lookup = MockAssetLookup({
        bnbId: bnb,
        usdtBep20Id: usdtBep20,
        cakeBep20Id: cakeBep20,
        ethId: eth,
        usdtErc20Id: usdtErc20,
        btcId: btc,
        ltcId: ltc,
        dogeId: doge,
        kmdId: kmd,
        maticId: matic,
        usdtMaticId: usdtMatic,
        usdcMaticId: usdcMatic,
        atomId: atom,
        osmoId: osmo,
        osmoTokenId: osmoToken,
      });
    });

    test('Primary asset forms its own group', () {
      final groups = AssetGroup.groupByPrimary([bnb], lookup);
      expect(groups.length, 1);
      expect(groups.first.primary, bnb);
      expect(groups.first.children, isNull);
    });

    test('Child asset is grouped under its parent', () {
      final groups = AssetGroup.groupByPrimary([usdtBep20], lookup);
      expect(groups.length, 1);
      expect(groups.first.primary, bnb);
      expect(groups.first.children, contains(usdtBep20));
    });

    test('Multiple children with same parent are grouped together', () {
      final groups = AssetGroup.groupByPrimary([usdtBep20, cakeBep20], lookup);
      expect(groups.length, 1);
      expect(groups.first.primary, bnb);
      expect(groups.first.children, containsAll([usdtBep20, cakeBep20]));
    });

    test('Parent and children together are grouped correctly', () {
      final groups = AssetGroup.groupByPrimary([
        bnb,
        usdtBep20,
        cakeBep20,
      ], lookup);
      expect(groups.length, 1);
      expect(groups.first.primary, bnb);
      expect(groups.first.children, containsAll([usdtBep20, cakeBep20]));
    });

    test('Multiple groups for different parents', () {
      final groups = AssetGroup.groupByPrimary([
        bnb,
        usdtBep20,
        eth,
        usdtErc20,
      ], lookup);
      expect(groups.length, 2);
      final bnbGroup = groups.firstWhereOrNull((g) => g.primary == bnb);
      final ethGroup = groups.firstWhereOrNull((g) => g.primary == eth);
      expect(bnbGroup, isNotNull);
      expect(ethGroup, isNotNull);
      expect(bnbGroup!.children, contains(usdtBep20));
      expect(ethGroup!.children, contains(usdtErc20));
    });

    test('Child with missing parent is skipped', () {
      final orphanId = makeAssetId(
        id: 'ORPHAN',
        name: 'ORPHAN',
        parentId: makeAssetId(id: 'MISSING', name: 'MISSING'),
      );
      final orphan = makeAsset(id: orphanId);
      final groups = AssetGroup.groupByPrimary([orphan], lookup);
      expect(groups, isEmpty);
    });

    test('No duplicates in groups', () {
      final groups = AssetGroup.groupByPrimary([
        bnb,
        usdtBep20,
        cakeBep20,
      ], lookup);
      final allAssets = [
        for (final g in groups) ...[g.primary, ...(g.children ?? {})],
      ];
      expect(allAssets.toSet().length, allAssets.length);
    });

    test('Order of input does not affect grouping', () {
      final group1 = AssetGroup.groupByPrimary([
        bnb,
        usdtBep20,
        cakeBep20,
      ], lookup);
      final group2 = AssetGroup.groupByPrimary([
        cakeBep20,
        bnb,
        usdtBep20,
      ], lookup);
      expect(group1.length, group2.length);
      expect(group1.first.primary, group2.first.primary);
      expect(group1.first.children, group2.first.children);
    });

    test('UTXO assets are grouped separately', () {
      final groups = AssetGroup.groupByPrimary([btc, ltc, doge, kmd], lookup);
      expect(groups.length, 4);
      expect(groups.map((g) => g.primary), containsAll([btc, ltc, doge, kmd]));
      expect(groups.every((g) => g.children == null), isTrue);
    });

    test('Polygon (MATIC) parent and children', () {
      final groups = AssetGroup.groupByPrimary([
        matic,
        usdtMatic,
        usdcMatic,
      ], lookup);
      expect(groups.length, 1);
      expect(groups.first.primary, matic);
      expect(groups.first.children, containsAll([usdtMatic, usdcMatic]));
    });

    test('Tendermint and TendermintToken', () {
      final groups = AssetGroup.groupByPrimary([osmo, osmoToken], lookup);
      expect(groups.length, 1);
      expect(groups.first.primary, osmo);
      expect(groups.first.children, contains(osmoToken));
    });

    test('Mix of all asset types', () {
      final groups = AssetGroup.groupByPrimary([
        bnb,
        usdtBep20,
        cakeBep20,
        eth,
        usdtErc20,
        btc,
        ltc,
        doge,
        kmd,
        matic,
        usdtMatic,
        usdcMatic,
        atom,
        osmo,
        osmoToken,
      ], lookup);
      // Should be one group for each parent: bnb, eth, btc, ltc, doge, kmd, matic, atom, osmo
      final expectedPrimaries = [
        bnb,
        eth,
        btc,
        ltc,
        doge,
        kmd,
        matic,
        atom,
        osmo,
      ];
      expect(groups.length, expectedPrimaries.length);
      expect(groups.map((g) => g.primary).toSet(), expectedPrimaries.toSet());
      // Check that all children are present in their groups
      final bnbGroup = groups.firstWhereOrNull((g) => g.primary == bnb);
      expect(bnbGroup!.children, containsAll([usdtBep20, cakeBep20]));
      final ethGroup = groups.firstWhereOrNull((g) => g.primary == eth);
      expect(ethGroup!.children, contains(usdtErc20));
      final maticGroup = groups.firstWhereOrNull((g) => g.primary == matic);
      expect(maticGroup!.children, containsAll([usdtMatic, usdcMatic]));
      final osmoGroup = groups.firstWhereOrNull((g) => g.primary == osmo);
      expect(osmoGroup!.children, contains(osmoToken));
    });
  });
}
