import 'package:komodo_defi_sdk/src/swaps/swap_strategies/_strategies_index.dart';
import 'package:test/test.dart';

void main() {
  group('SwapStrategyFactory', () {
    late SwapStrategyFactory factory;

    setUp(() {
      factory = const SwapStrategyFactory();
    });

    test('should create smart strategy', () {
      final strategy = factory.createStrategy(SwapStrategyType.smart);
      expect(strategy, isA<SmartSwapStrategy>());
      expect(strategy.name, equals('Smart'));
    });

    test('should create taker strategy', () {
      final strategy = factory.createStrategy(SwapStrategyType.taker);
      expect(strategy, isA<TakerSwapStrategy>());
      expect(strategy.name, equals('Taker'));
    });

    test('should create maker strategy', () {
      final strategy = factory.createStrategy(SwapStrategyType.maker);
      expect(strategy, isA<MakerSwapStrategy>());
      expect(strategy.name, equals('Maker'));
    });

    test('should return smart strategy as default', () {
      final strategy = factory.defaultStrategy;
      expect(strategy, isA<SmartSwapStrategy>());
    });

    test('should return available strategies with descriptions', () {
      final strategies = factory.availableStrategies;
      expect(strategies, hasLength(3));
      expect(
        strategies.keys,
        containsAll([
          SwapStrategyType.smart,
          SwapStrategyType.taker,
          SwapStrategyType.maker,
        ]),
      );
      expect(strategies.values.every((desc) => desc.isNotEmpty), isTrue);
    });
  });

  group('Strategy Names and Descriptions', () {
    test('SmartSwapStrategy should have correct name and description', () {
      const strategy = SmartSwapStrategy();
      expect(strategy.name, equals('Smart'));
      expect(strategy.description, contains('orderbook'));
      expect(strategy.description, contains('taker'));
      expect(strategy.description, contains('maker'));
    });

    test('TakerSwapStrategy should have correct name and description', () {
      const strategy = TakerSwapStrategy();
      expect(strategy.name, equals('Taker'));
      expect(strategy.description, contains('taker'));
      expect(strategy.description, contains('fail'));
    });

    test('MakerSwapStrategy should have correct name and description', () {
      const strategy = MakerSwapStrategy();
      expect(strategy.name, equals('Maker'));
      expect(strategy.description, contains('maker'));
      expect(strategy.description, contains('wait'));
    });
  });
}
