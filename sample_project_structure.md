# Sample Project Structure for Crypto Collector Game

## Project Setup

### 1. Create New Flutter Project
```bash
flutter create crypto_collector_game
cd crypto_collector_game
```

### 2. Update pubspec.yaml
```yaml
name: crypto_collector_game
description: A 2D trading game built with Flame and Komodo DeFi SDK

publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: ^3.7.0
  flutter: ">=3.29.0 <3.36.0"

dependencies:
  flutter:
    sdk: flutter
  
  # Game Engine
  flame: ^1.16.0
  
  # Komodo DeFi SDK
  komodo_defi_sdk: ^2.5.0
  komodo_defi_framework: ^2.5.0
  komodo_coins: ^2.5.0
  komodo_cex_market_data: ^2.5.0
  komodo_defi_types: ^2.5.0
  
  # UI and Utilities
  cupertino_icons: ^1.0.8
  flutter_secure_storage: ^10.0.0-beta.4

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/audio/
```

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── game/
│   ├── crypto_collector_game.dart     # Main game class
│   ├── components/
│   │   ├── player.dart               # Player character
│   │   ├── coin.dart                 # Collectible coins
│   │   ├── platform.dart             # Game platforms
│   │   └── enemy.dart                # Game enemies (optional)
│   └── systems/
│       ├── trading_system.dart       # DeFi trading logic
│       ├── collision_system.dart     # Game collision detection
│       └── audio_system.dart         # Sound effects
├── services/
│   ├── komodo_service.dart           # Komodo DeFi integration
│   ├── market_data_service.dart      # Real-time market data
│   └── storage_service.dart          # Local data persistence
├── ui/
│   ├── trading_ui.dart               # Trading interface
│   ├── game_ui.dart                  # Game HUD
│   ├── menu_ui.dart                  # Main menu
│   └── widgets/
│       ├── coin_display.dart         # Coin balance display
│       ├── trade_button.dart         # Trading buttons
│       └── price_chart.dart          # Price charts (advanced)
├── models/
│   ├── game_state.dart               # Game state management
│   ├── trade_result.dart             # Trading result data
│   └── market_data.dart              # Market data models
└── utils/
    ├── constants.dart                # Game constants
    ├── helpers.dart                  # Utility functions
    └── extensions.dart               # Dart extensions
```

## Starter Code Files

### 1. main.dart
```dart
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game/crypto_collector_game.dart';

void main() {
  runApp(const CryptoCollectorApp());
}

class CryptoCollectorApp extends StatelessWidget {
  const CryptoCollectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto Collector',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        brightness: Brightness.dark,
        fontFamily: 'Roboto',
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GameWidget(
        game: CryptoCollectorGame(),
        overlayBuilderMap: {
          'menu': (context, game) => MenuUI(game: game),
          'trading': (context, game) => TradingUI(game: game),
          'game': (context, game) => GameUI(game: game),
        },
        initialActiveOverlays: ['menu'],
      ),
    );
  }
}
```

### 2. game/crypto_collector_game.dart
```dart
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'components/player.dart';
import 'components/coin.dart';
import 'components/platform.dart';
import 'systems/trading_system.dart';
import '../services/komodo_service.dart';
import '../ui/game_ui.dart';

class CryptoCollectorGame extends FlameGame 
    with KeyboardEvents, HasCollisionDetection {
  
  late Player player;
  late TradingSystem tradingSystem;
  late KomodoService komodoService;
  
  double coinsCollected = 0.0;
  String currentCoin = 'KMD';
  bool isGameInitialized = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Initialize services
    await _initializeServices();
    
    // Add game components
    await _addGameComponents();
    
    // Add UI overlay
    add(GameUI());
    
    isGameInitialized = true;
  }

  Future<void> _initializeServices() async {
    komodoService = KomodoService();
    await komodoService.initialize();
    
    tradingSystem = TradingSystem(komodoService);
  }

  Future<void> _addGameComponents() async {
    // Add player
    player = Player();
    add(player);
    
    // Add coins
    addAll([
      Coin(Vector2(100, 300)),
      Coin(Vector2(200, 250)),
      Coin(Vector2(350, 400)),
      Coin(Vector2(500, 350)),
      Coin(Vector2(650, 300)),
    ]);
    
    // Add platforms
    addAll([
      Platform(Vector2(0, 500), Vector2(size.x, 100)),
      Platform(Vector2(150, 400), Vector2(100, 20)),
      Platform(Vector2(300, 350), Vector2(100, 20)),
      Platform(Vector2(450, 300), Vector2(100, 20)),
    ]);
  }

  void collectCoin() {
    coinsCollected += 1.0;
    // Trigger UI update
  }

  Future<void> tradeCoins(String targetCoin) async {
    if (coinsCollected > 0) {
      try {
        final result = await tradingSystem.performSwap(
          currentCoin, 
          targetCoin, 
          coinsCollected
        );
        
        if (result['success'] == true) {
          coinsCollected = 0.0;
          currentCoin = targetCoin;
          // Show success message
        } else {
          // Show error message
        }
      } catch (e) {
        // Handle error
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Game logic updates
  }
}
```

### 3. services/komodo_service.dart
```dart
import 'package:komodo_defi_framework/komodo_defi_framework.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class KomodoService {
  late KomodoDefiFramework _framework;
  bool _isInitialized = false;

  Future<void> initialize() async {
    try {
      // Configure local KDF instance
      final config = LocalConfig(userpass: 'your-secure-password');
      _framework = KomodoDefiFramework(config: config);
      
      // Start KDF with seed phrase (use a test seed for demo)
      final result = await _framework.startKdf('your-seed-phrase');
      
      if (result.isRunning()) {
        _isInitialized = true;
        print('Komodo DeFi Framework started successfully!');
      } else {
        throw Exception('Failed to start KDF: ${result.toString()}');
      }
    } catch (e) {
      print('Error initializing Komodo service: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getBalance(String coin) async {
    if (!_isInitialized) {
      throw Exception('KDF not initialized');
    }
    
    try {
      final response = await _framework.executeRpc({
        'method': 'get_balance',
        'params': {'coin': coin}
      });
      
      return response;
    } catch (e) {
      print('Error getting balance: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createSwap(
    String fromCoin, 
    String toCoin, 
    double amount
  ) async {
    if (!_isInitialized) {
      throw Exception('KDF not initialized');
    }
    
    try {
      final response = await _framework.executeRpc({
        'method': 'setprice',
        'params': {
          'base': fromCoin,
          'rel': toCoin,
          'volume': amount.toString(),
          'price': '0.1', // Simplified for demo
          'max': true
        }
      });
      
      return response;
    } catch (e) {
      print('Error creating swap: $e');
      rethrow;
    }
  }

  Future<void> dispose() async {
    if (_isInitialized) {
      try {
        await _framework.kdfStop();
        _isInitialized = false;
      } catch (e) {
        print('Error stopping KDF: $e');
      }
    }
  }
}
```

### 4. services/market_data_service.dart
```dart
import 'package:komodo_cex_market_data/komodo_cex_market_data.dart';

class MarketDataService {
  late KomodoCexMarketData _marketData;
  bool _isInitialized = false;

  Future<void> initialize() async {
    try {
      _marketData = KomodoCexMarketData();
      _isInitialized = true;
    } catch (e) {
      print('Error initializing market data service: $e');
      rethrow;
    }
  }

  Future<double> getPrice(String coin) async {
    if (!_isInitialized) {
      throw Exception('Market data service not initialized');
    }
    
    try {
      final data = await _marketData.getTicker(coin);
      return double.parse(data['last'] ?? '0.0');
    } catch (e) {
      print('Error getting price for $coin: $e');
      // Return fallback price for demo
      return _getFallbackPrice(coin);
    }
  }

  Future<Map<String, dynamic>> getMarketData(String coin) async {
    if (!_isInitialized) {
      throw Exception('Market data service not initialized');
    }
    
    try {
      return await _marketData.getTicker(coin);
    } catch (e) {
      print('Error getting market data for $coin: $e');
      return _getFallbackMarketData(coin);
    }
  }

  double _getFallbackPrice(String coin) {
    // Fallback prices for demo purposes
    switch (coin.toUpperCase()) {
      case 'BTC':
        return 45000.0;
      case 'ETH':
        return 3000.0;
      case 'KMD':
        return 0.5;
      default:
        return 1.0;
    }
  }

  Map<String, dynamic> _getFallbackMarketData(String coin) {
    return {
      'last': _getFallbackPrice(coin).toString(),
      'high': (_getFallbackPrice(coin) * 1.1).toString(),
      'low': (_getFallbackPrice(coin) * 0.9).toString(),
      'volume': '1000.0',
    };
  }
}
```

### 5. game/systems/trading_system.dart
```dart
import '../../services/komodo_service.dart';
import '../../services/market_data_service.dart';

class TradingSystem {
  final KomodoService _komodoService;
  final MarketDataService _marketDataService;
  
  TradingSystem(this._komodoService) 
      : _marketDataService = MarketDataService();

  Future<void> initialize() async {
    await _marketDataService.initialize();
  }

  Future<Map<String, dynamic>> performSwap(
    String fromCoin, 
    String toCoin, 
    double amount
  ) async {
    try {
      // Get current market price
      final price = await _marketDataService.getPrice(fromCoin);
      
      // Create swap order
      final result = await _komodoService.createSwap(fromCoin, toCoin, amount);
      
      return {
        'success': true,
        'transaction_id': result['txid'] ?? 'demo-tx-${DateTime.now().millisecondsSinceEpoch}',
        'amount': amount,
        'price': price,
        'from_coin': fromCoin,
        'to_coin': toCoin,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'from_coin': fromCoin,
        'to_coin': toCoin,
        'amount': amount,
      };
    }
  }

  Future<double> getExchangeRate(String fromCoin, String toCoin) async {
    try {
      final fromPrice = await _marketDataService.getPrice(fromCoin);
      final toPrice = await _marketDataService.getPrice(toCoin);
      
      if (toPrice > 0) {
        return fromPrice / toPrice;
      }
      return 1.0; // Fallback rate
    } catch (e) {
      print('Error getting exchange rate: $e');
      return 1.0; // Fallback rate
    }
  }

  Future<Map<String, double>> getBalances(List<String> coins) async {
    final balances = <String, double>{};
    
    for (final coin in coins) {
      try {
        final balance = await _komodoService.getBalance(coin);
        balances[coin] = double.parse(balance['balance'] ?? '0.0');
      } catch (e) {
        print('Error getting balance for $coin: $e');
        balances[coin] = 0.0;
      }
    }
    
    return balances;
  }
}
```

### 6. ui/trading_ui.dart
```dart
import 'package:flutter/material.dart';
import '../game/crypto_collector_game.dart';

class TradingUI extends StatelessWidget {
  final CryptoCollectorGame game;
  
  const TradingUI({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.currency_bitcoin, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Crypto Collector',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Coins: ${game.coinsCollected.toStringAsFixed(2)} ${game.currentCoin}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Trade for:',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildTradeButton('BTC', Colors.orange),
                const SizedBox(width: 8),
                _buildTradeButton('ETH', Colors.blue),
                const SizedBox(width: 8),
                _buildTradeButton('KMD', Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTradeButton(String coin, Color color) {
    return GestureDetector(
      onTap: () => game.tradeCoins(coin),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Text(
          coin,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
```

## Assets Structure

```
assets/
├── images/
│   ├── player/
│   │   ├── player_idle.png
│   │   ├── player_run.png
│   │   └── player_jump.png
│   ├── coins/
│   │   ├── coin_gold.png
│   │   ├── coin_silver.png
│   │   └── coin_bronze.png
│   ├── platforms/
│   │   └── platform.png
│   └── ui/
│       ├── background.png
│       └── icons/
├── audio/
│   ├── collect_coin.wav
│   ├── trade_success.wav
│   └── background_music.mp3
└── fonts/
    └── game_font.ttf
```

## Running the Project

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run on Web (Recommended for Demo)
```bash
flutter run -d chrome
```

### 3. Run on Mobile
```bash
flutter run -d android
# or
flutter run -d ios
```

### 4. Build for Production
```bash
flutter build web
flutter build apk
flutter build ios
```

## Next Steps

1. **Add Game Assets:** Create or download sprites and audio files
2. **Implement Advanced Features:** Add more game mechanics and trading pairs
3. **Add Animations:** Implement smooth transitions and particle effects
4. **Multiplayer Support:** Add real-time multiplayer trading
5. **NFT Integration:** Include NFT trading functionality
6. **Analytics:** Track user engagement and trading patterns

This structure provides a solid foundation for building the Crypto Collector game and can be easily extended with additional features and improvements.