// Example implementation of key concepts from the GameFi tutorial
// This file demonstrates how to integrate Komodo DeFi SDK with a Flame game

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';

// ============================================================================
// GAME SETUP: Basic Flame game with DeFi integration
// ============================================================================

class GameFiDemo extends FlameGame with HasTappableComponents {
  late final DeFiManager defiManager;
  late final TradingPost tradingPost;
  late final WalletDisplay walletDisplay;

  @override
  Future<void> onLoad() async {
    // Initialize DeFi manager
    defiManager = DeFiManager();
    await defiManager.initialize();

    // Create game world
    final world = World(children: [
      // Trading post where players can swap cryptocurrencies
      tradingPost = TradingPost(
        position: Vector2(size.x * 0.8, size.y * 0.3),
        defiManager: defiManager,
      ),
      
      // Wallet display showing current balances
      walletDisplay = WalletDisplay(
        position: Vector2(20, 20),
        defiManager: defiManager,
      ),
      
      // Player character
      Player(position: size / 2),
    ]);

    final camera = CameraComponent(world: world);
    await addAll([world, camera]);
  }
}

// ============================================================================
// DEFI MANAGER: Handles all blockchain interactions
// ============================================================================

class DeFiManager {
  late KomodoDefiSdk _sdk;
  KdfUser? _currentUser;
  
  // Available trading pairs for the game
  static const List<TradingPair> gameTradingPairs = [
    TradingPair(from: 'BTC', to: 'ETH'),
    TradingPair(from: 'ETH', to: 'USDT'),
    TradingPair(from: 'BTC', to: 'USDT'),
  ];

  Future<void> initialize() async {
    try {
      _sdk = KomodoDefiSdk(config: const KomodoDefiSdkConfig());
      await _sdk.initialize();
      print('DeFi SDK initialized successfully');
    } catch (e) {
      print('Failed to initialize DeFi SDK: $e');
    }
  }

  Future<bool> createGameWallet(String password) async {
    try {
      // Generate a new wallet for the player
      final user = await _sdk.auth.createWallet(
        walletId: WalletId(name: 'GameWallet_${DateTime.now().millisecondsSinceEpoch}'),
        password: password,
      );
      
      _currentUser = user;
      return true;
    } catch (e) {
      print('Failed to create wallet: $e');
      return false;
    }
  }

  Future<Map<String, double>> getBalances() async {
    if (_currentUser == null) return {};
    
    try {
      // Get balances for common game currencies
      final balances = <String, double>{};
      
      for (final currency in ['BTC', 'ETH', 'USDT']) {
        try {
          final balance = await _sdk.trading.getBalance(currency);
          balances[currency] = balance.toDouble();
        } catch (e) {
          balances[currency] = 0.0;
        }
      }
      
      return balances;
    } catch (e) {
      print('Failed to get balances: $e');
      return {};
    }
  }

  Future<SwapResult?> executeGameSwap({
    required String fromCurrency,
    required String toCurrency,
    required double amount,
  }) async {
    if (_currentUser == null) return null;

    try {
      // Get quote first
      final quote = await _sdk.trading.getSwapQuote(
        from: fromCurrency,
        to: toCurrency,
        amount: amount,
      );

      // Execute the swap
      final result = await _sdk.trading.executeSwap(quote: quote);
      
      print('Swap executed: ${amount} ${fromCurrency} -> ${result.toAmount} ${toCurrency}');
      return result;
    } catch (e) {
      print('Swap failed: $e');
      return null;
    }
  }

  bool get hasWallet => _currentUser != null;
  KdfUser? get currentUser => _currentUser;
}

// ============================================================================
// TRADING POST: Interactive game component for swapping currencies
// ============================================================================

class TradingPost extends PositionComponent with TapCallbacks, HasGameRef {
  final DeFiManager defiManager;
  late SpriteComponent _sprite;
  late CircleComponent _interactionZone;

  TradingPost({
    required super.position,
    required this.defiManager,
  }) : super(size: Vector2.all(64), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // Visual representation (in a real game, you'd load actual sprites)
    _sprite = SpriteComponent(
      size: size,
      paint: Paint()..color = Colors.brown,
    );
    
    _interactionZone = CircleComponent(
      radius: 40,
      paint: Paint()..color = Colors.yellow.withOpacity(0.3),
      anchor: Anchor.center,
    );
    
    await addAll([_sprite, _interactionZone]);
  }

  @override
  bool onTapDown(TapDownEvent event) {
    if (defiManager.hasWallet) {
      _openTradingInterface();
    } else {
      _showWalletRequiredMessage();
    }
    return true;
  }

  void _openTradingInterface() {
    // In a real implementation, this would show a trading dialog
    print('Opening trading interface...');
    
    // Example: Execute a small trade
    defiManager.executeGameSwap(
      fromCurrency: 'BTC',
      toCurrency: 'ETH',
      amount: 0.001, // Small amount for demo
    ).then((result) {
      if (result != null) {
        _showTradeSuccess(result);
      } else {
        _showTradeError();
      }
    });
  }

  void _showWalletRequiredMessage() {
    print('Please create a wallet first!');
  }

  void _showTradeSuccess(SwapResult result) {
    print('Trade successful! You received ${result.toAmount} ${result.toCurrency}');
    
    // Update visual feedback
    add(
      TextComponent(
        text: 'Trade Success!',
        position: Vector2(0, -30),
        anchor: Anchor.center,
        textRenderer: TextPaint(
          style: const TextStyle(color: Colors.green, fontSize: 12),
        ),
      )..removeAfter(2.0), // Remove after 2 seconds
    );
  }

  void _showTradeError() {
    print('Trade failed. Please try again.');
    
    add(
      TextComponent(
        text: 'Trade Failed',
        position: Vector2(0, -30),
        anchor: Anchor.center,
        textRenderer: TextPaint(
          style: const TextStyle(color: Colors.red, fontSize: 12),
        ),
      )..removeAfter(2.0),
    );
  }
}

// ============================================================================
// WALLET DISPLAY: Shows current cryptocurrency balances
// ============================================================================

class WalletDisplay extends PositionComponent with HasGameRef {
  final DeFiManager defiManager;
  late RectangleComponent _background;
  late List<TextComponent> _balanceTexts;
  
  WalletDisplay({
    required super.position,
    required this.defiManager,
  }) : super(size: Vector2(200, 120));

  @override
  Future<void> onLoad() async {
    _background = RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.black.withOpacity(0.8),
    );
    
    _balanceTexts = [];
    
    await add(_background);
    await _setupBalanceDisplay();
    
    // Update balances periodically
    add(TimerComponent(
      period: 5.0, // Update every 5 seconds
      repeat: true,
      onTick: _updateBalances,
    ));
  }

  Future<void> _setupBalanceDisplay() async {
    // Title
    await add(TextComponent(
      text: 'Wallet',
      position: Vector2(10, 10),
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
      ),
    ));
    
    // Create balance text components
    final currencies = ['BTC', 'ETH', 'USDT'];
    for (int i = 0; i < currencies.length; i++) {
      final balanceText = TextComponent(
        text: '${currencies[i]}: --',
        position: Vector2(10, 30 + (i * 20)),
        textRenderer: TextPaint(
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      );
      
      _balanceTexts.add(balanceText);
      await add(balanceText);
    }
    
    await _updateBalances();
  }

  Future<void> _updateBalances() async {
    if (!defiManager.hasWallet) {
      for (final text in _balanceTexts) {
        text.text = text.text.split(':')[0] + ': No wallet';
      }
      return;
    }

    final balances = await defiManager.getBalances();
    final currencies = ['BTC', 'ETH', 'USDT'];
    
    for (int i = 0; i < currencies.length && i < _balanceTexts.length; i++) {
      final currency = currencies[i];
      final balance = balances[currency] ?? 0.0;
      _balanceTexts[i].text = '$currency: ${balance.toStringAsFixed(4)}';
    }
  }
}

// ============================================================================
// PLAYER: Basic player character
// ============================================================================

class Player extends PositionComponent with HasGameRef {
  Player({required super.position}) 
      : super(size: Vector2.all(32), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // Simple player representation
    await add(
      RectangleComponent(
        size: size,
        paint: Paint()..color = Colors.blue,
      ),
    );
  }
}

// ============================================================================
// HELPER CLASSES
// ============================================================================

class TradingPair {
  final String from;
  final String to;
  
  const TradingPair({required this.from, required this.to});
}

// Extension to add removeAfter functionality to components
extension ComponentExtensions on Component {
  void removeAfter(double seconds) {
    add(TimerComponent(
      period: seconds,
      removeOnFinish: true,
      onTick: () => removeFromParent(),
    ));
  }
}

// ============================================================================
// INTEGRATION EXAMPLE: How to use this in a Flutter app
// ============================================================================

class GameFiDemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GameFi Demo',
      home: Scaffold(
        body: GameWidget<GameFiDemo>.controlled(
          gameFactory: GameFiDemo.new,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Example: Create wallet button
            _showWalletCreationDialog(context);
          },
          child: Icon(Icons.account_balance_wallet),
        ),
      ),
    );
  }

  void _showWalletCreationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create Game Wallet'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Create a new wallet to start trading cryptocurrencies in-game!'),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // In real implementation, get password from TextField
              // and call defiManager.createGameWallet(password)
              Navigator.pop(context);
            },
            child: Text('Create Wallet'),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// USAGE NOTES
// ============================================================================

/*
This example demonstrates the key concepts from the GameFi tutorial:

1. **DeFi Integration**: The DeFiManager class shows how to initialize and use
   the Komodo DeFi SDK within a game context.

2. **Game Components**: TradingPost and WalletDisplay show how to create
   game components that interact with real blockchain functionality.

3. **User Experience**: The integration feels natural - players interact with
   in-game objects to perform real cryptocurrency operations.

4. **Error Handling**: Proper error handling ensures the game doesn't break
   when blockchain operations fail.

5. **Real-time Updates**: Wallet balances update automatically, keeping
   players informed of their actual cryptocurrency holdings.

To use this in a real project:

1. Add the required dependencies to pubspec.yaml
2. Implement proper error handling and user feedback
3. Add visual assets and animations
4. Implement security best practices for wallet management
5. Add more sophisticated trading mechanics and game progression

This code serves as a starting point for developers who want to create
GameFi experiences using Flame and the Komodo DeFi SDK.
*/