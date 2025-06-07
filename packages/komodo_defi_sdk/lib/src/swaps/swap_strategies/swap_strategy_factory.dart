import 'package:komodo_defi_sdk/src/swaps/swap_strategies/maker_swap_strategy.dart';
import 'package:komodo_defi_sdk/src/swaps/swap_strategies/smart_swap_strategy.dart';
import 'package:komodo_defi_sdk/src/swaps/swap_strategies/swap_strategy.dart';
import 'package:komodo_defi_sdk/src/swaps/swap_strategies/taker_swap_strategy.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Available swap strategy types
enum SwapStrategyType {
  /// Smart strategy that checks orderbook and acts accordingly
  smart,

  /// Taker strategy that places taker orders immediately
  taker,

  /// Maker strategy that places maker orders
  maker,
}

/// Factory for creating swap strategies
class SwapStrategyFactory {
  /// Creates a new swap strategy factory
  const SwapStrategyFactory();

  /// Creates a strategy based on the given type
  SwapStrategy createStrategy(SwapStrategyType type) {
    switch (type) {
      case SwapStrategyType.smart:
        return const SmartSwapStrategy();
      case SwapStrategyType.taker:
        return const TakerSwapStrategy();
      case SwapStrategyType.maker:
        return const MakerSwapStrategy();
    }
  }

  /// Creates a strategy based on swap parameters or defaults to smart
  SwapStrategy createStrategyForParameters(SwapParameters parameters) {
    // Here you could add logic to automatically select strategy based on parameters
    // For now, default to smart strategy
    return createStrategy(SwapStrategyType.smart);
  }

  /// Returns the default strategy
  SwapStrategy get defaultStrategy => createStrategy(SwapStrategyType.smart);

  /// Returns all available strategies with their descriptions
  Map<SwapStrategyType, String> get availableStrategies => {
    SwapStrategyType.smart: const SmartSwapStrategy().description,
    SwapStrategyType.taker: const TakerSwapStrategy().description,
    SwapStrategyType.maker: const MakerSwapStrategy().description,
  };
}
