# Building a 2D Trading Game with Flame and Komodo DeFi SDK
## 30-Minute Tutorial Script

### Video Overview
**Title:** "Create a 2D Trading Game in 30 Minutes with Flame and Komodo DeFi SDK"
**Duration:** 30 minutes
**Target Audience:** Flutter developers interested in game development and DeFi integration
**Skill Level:** Intermediate (basic Flutter knowledge required)

---

## Script Outline

### Introduction (2 minutes)
**Visual:** Title screen with Komodo DeFi SDK and Flame logos

**Narrator:**
"Welcome to this exciting tutorial where we'll build a 2D trading game using Flame game engine and the powerful Komodo DeFi SDK. By the end of this 30-minute session, you'll have a fully functional game where players can collect coins, trade them for different cryptocurrencies, and see real-time market data integration.

The game we're building is called 'Crypto Collector' - a simple but engaging 2D platformer where players navigate through levels, collect coins, and use the Komodo DeFi SDK to perform actual cryptocurrency swaps. This demonstrates the incredible power and ease of integrating DeFi functionality into Flutter games."

**Key Points to Highlight:**
- Real DeFi integration in a game
- Cross-platform compatibility
- Simplified development with Komodo SDK
- Practical use case for game developers

---

### Prerequisites and Setup (3 minutes)
**Visual:** Code editor, terminal, and setup screens

**Narrator:**
"Before we dive into coding, let's make sure you have everything set up. You'll need Flutter SDK 3.29.0 or higher, Dart SDK 3.7.0 or higher, and a code editor like VS Code or Android Studio.

For this tutorial, we'll be using the Komodo DeFi SDK which provides a high-level abstraction layer for DeFi operations, making it incredibly easy to integrate cryptocurrency trading into your Flutter applications."

**Setup Steps:**
1. Flutter and Dart SDK installation verification
2. Creating a new Flutter project
3. Adding dependencies to pubspec.yaml
4. Brief overview of the Komodo DeFi SDK architecture

**Code to Show:**
```yaml
dependencies:
  flutter:
    sdk: flutter
  flame: ^1.16.0
  komodo_defi_sdk: ^2.5.0
  komodo_defi_types: ^2.5.0
  komodo_ui: ^2.5.0  # Optional - for UI components
```

---

### Project Structure and Architecture (2 minutes)
**Visual:** Project folder structure diagram

**Narrator:**
"Our game will follow a clean architecture pattern with separate layers for game logic, DeFi integration, and UI. The Komodo DeFi SDK handles all the complex blockchain interactions, allowing us to focus on creating an engaging gaming experience."

**Project Structure:**
```
lib/
├── main.dart
├── game/
│   ├── crypto_collector_game.dart
│   ├── components/
│   │   ├── player.dart
│   │   ├── coin.dart
│   │   └── platform.dart
│   └── systems/
│       └── trading_system.dart
├── services/
│   ├── komodo_service.dart
│   └── market_data_service.dart
└── ui/
    ├── trading_ui.dart
    └── game_ui.dart
```

---

### Setting Up the Komodo DeFi SDK (5 minutes)
**Visual:** Code implementation with live coding

**Narrator:**
"Let's start by setting up the Komodo DeFi SDK. This is where the magic happens - we'll use the high-level SDK that abstracts away all the complex underlying logic and provides a simple, intuitive API for DeFi operations."

**Implementation Steps:**

1. **Create Game Service with Komodo SDK**
```dart
class GameDeFiService {
  late KomodoDefiSdk _sdk;
  bool _isInitialized = false;

  Future<void> initialize() async {
    // Create SDK with default local configuration
    _sdk = KomodoDefiSdk();
    await _sdk.initialize();
    _isInitialized = true;
    print('Komodo DeFi SDK initialized successfully!');
  }

  Future<void> authenticateUser(String password, String walletName) async {
    if (!_isInitialized) throw Exception('SDK not initialized');
    
    // Sign in user with wallet
    await _sdk.auth.signIn(
      password: password,
      walletId: WalletId(walletName),
    );
  }

  Future<Map<String, double>> getBalances(List<String> tickers) async {
    if (!_isInitialized) throw Exception('SDK not initialized');
    
    final balances = <String, double>{};
    
    for (final ticker in tickers) {
      try {
        // Find asset by ticker
        final assets = _sdk.assets.findAssetsByTicker(ticker);
        if (assets.isNotEmpty) {
          final asset = assets.first;
          
          // Get balance for the asset
          final balance = await _sdk.balances.getBalance(asset);
          balances[ticker] = balance.available.toDouble();
        }
      } catch (e) {
        print('Error getting balance for $ticker: $e');
        balances[ticker] = 0.0;
      }
    }
    
    return balances;
  }

  Future<Map<String, dynamic>> performSwap(
    String fromTicker, 
    String toTicker, 
    double amount
  ) async {
    if (!_isInitialized) throw Exception('SDK not initialized');
    
    try {
      // Find assets by ticker
      final fromAssets = _sdk.assets.findAssetsByTicker(fromTicker);
      final toAssets = _sdk.assets.findAssetsByTicker(toTicker);
      
      if (fromAssets.isEmpty || toAssets.isEmpty) {
        throw Exception('Asset not found');
      }
      
      final fromAsset = fromAssets.first;
      final toAsset = toAssets.first;
      
      // Get current market price
      final price = await _sdk.marketData.getPrice(fromAsset);
      
      // Create swap order using the swap manager
      final order = await _sdk.swaps.placeOrder(
        baseAsset: fromAsset,
        relAsset: toAsset,
        volume: amount,
        price: price,
        side: OrderSide.sell,
      );
      
      return {
        'success': true,
        'order_id': order.orderId,
        'amount': amount,
        'price': price,
        'from_asset': fromTicker,
        'to_asset': toTicker,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'from_asset': fromTicker,
        'to_asset': toTicker,
        'amount': amount,
      };
    }
  }

  Future<double> getPrice(String ticker) async {
    if (!_isInitialized) throw Exception('SDK not initialized');
    
    try {
      final assets = _sdk.assets.findAssetsByTicker(ticker);
      if (assets.isNotEmpty) {
        return await _sdk.marketData.getPrice(assets.first);
      }
      return 0.0;
    } catch (e) {
      print('Error getting price for $ticker: $e');
      return _getFallbackPrice(ticker);
    }
  }

  double _getFallbackPrice(String ticker) {
    // Fallback prices for demo purposes
    switch (ticker.toUpperCase()) {
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

  Future<void> dispose() async {
    if (_isInitialized) {
      await _sdk.dispose();
      _isInitialized = false;
    }
  }
}
```

**Key Points:**
- High-level SDK abstracts complex blockchain operations
- Simple, intuitive API for DeFi functionality
- Built-in authentication and wallet management
- Real-time market data and trading capabilities

---

### Building the Game with Flame (8 minutes)
**Visual:** Game development with live coding and game preview

**Narrator:**
"Now let's build our 2D platformer game using Flame. We'll create a simple but engaging game where players collect coins and can trade them for different cryptocurrencies."

**Implementation Steps:**

1. **Main Game Class**
```dart
class CryptoCollectorGame extends FlameGame {
  late Player player;
  late TradingSystem tradingSystem;
  late GameDeFiService defiService;
  
  double coinsCollected = 0.0;
  String currentCoin = 'KMD';

  @override
  Future<void> onLoad() async {
    // Initialize services
    await _initializeServices();
    
    // Add game components
    add(player = Player());
    addAll([
      Coin(Vector2(100, 300)),
      Coin(Vector2(200, 250)),
      Coin(Vector2(350, 400)),
      Platform(Vector2(0, 500), Vector2(size.x, 100)),
    ]);
    
    // Add UI overlay
    add(GameUI());
  }

  Future<void> _initializeServices() async {
    defiService = GameDeFiService();
    await defiService.initialize();
    
    // Authenticate user (in a real app, you'd get this from user input)
    await defiService.authenticateUser('demo-password', 'game-wallet');
    
    tradingSystem = TradingSystem(defiService);
  }

  void collectCoin() {
    coinsCollected += 1.0;
    // Update UI
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
        }
      } catch (e) {
        // Show error message
      }
    }
  }
}
```

2. **Player Component**
```dart
class Player extends SpriteAnimationComponent 
    with HasGameRef<CryptoCollectorGame>, KeyboardHandler {
  
  static const double speed = 200.0;
  static const double jumpSpeed = -400.0;
  
  late SpriteAnimation idleAnimation;
  late SpriteAnimation runAnimation;
  late SpriteAnimation jumpAnimation;
  
  Vector2 velocity = Vector2.zero();
  bool isOnGround = false;

  @override
  Future<void> onLoad() async {
    // Load player sprites and animations
    idleAnimation = SpriteAnimation.fromFrameData(
      gameRef.images.fromCache('player_idle.png'),
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.1,
        textureSize: Vector2(32, 32),
      ),
    );
    
    animation = idleAnimation;
    size = Vector2(32, 32);
    position = Vector2(50, 300);
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Apply gravity
    velocity.y += 800 * dt;
    
    // Update position
    position += velocity * dt;
    
    // Ground collision
    if (position.y > 450) {
      position.y = 450;
      velocity.y = 0;
      isOnGround = true;
    }
    
    // Update animation
    if (!isOnGround) {
      animation = jumpAnimation;
    } else if (velocity.x.abs() > 0) {
      animation = runAnimation;
    } else {
      animation = idleAnimation;
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.keyA:
        case LogicalKeyboardKey.arrowLeft:
          velocity.x = -speed;
          break;
        case LogicalKeyboardKey.keyD:
        case LogicalKeyboardKey.arrowRight:
          velocity.x = speed;
          break;
        case LogicalKeyboardKey.space:
        case LogicalKeyboardKey.arrowUp:
          if (isOnGround) {
            velocity.y = jumpSpeed;
            isOnGround = false;
          }
          break;
      }
    } else if (event is KeyUpEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.keyA:
        case LogicalKeyboardKey.arrowLeft:
        case LogicalKeyboardKey.keyD:
        case LogicalKeyboardKey.arrowRight:
          velocity.x = 0;
          break;
      }
    }
    return super.onKeyEvent(event, keysPressed);
  }
}
```

3. **Coin Component**
```dart
class Coin extends SpriteComponent with HasGameRef<CryptoCollectorGame> {
  
  @override
  Future<void> onLoad() async {
    sprite = Sprite(gameRef.images.fromCache('coin.png'));
    size = Vector2(20, 20);
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Check collision with player
    if (gameRef.player.toRect().overlaps(toRect())) {
      gameRef.collectCoin();
      removeFromParent();
    }
  }
}
```

4. **Trading System**
```dart
class TradingSystem {
  final GameDeFiService _defiService;
  
  TradingSystem(this._defiService);

  Future<Map<String, dynamic>> performSwap(
    String fromTicker, 
    String toTicker, 
    double amount
  ) async {
    try {
      // Perform swap using the DeFi service
      final result = await _defiService.performSwap(fromTicker, toTicker, amount);
      
      return result;
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'from_ticker': fromTicker,
        'to_ticker': toTicker,
        'amount': amount,
      };
    }
  }

  Future<double> getExchangeRate(String fromTicker, String toTicker) async {
    try {
      final fromPrice = await _defiService.getPrice(fromTicker);
      final toPrice = await _defiService.getPrice(toTicker);
      
      if (toPrice > 0) {
        return fromPrice / toPrice;
      }
      return 1.0; // Fallback rate
    } catch (e) {
      print('Error getting exchange rate: $e');
      return 1.0; // Fallback rate
    }
  }

  Future<Map<String, double>> getBalances(List<String> tickers) async {
    return await _defiService.getBalances(tickers);
  }
}
```

---

### Creating the Trading UI (5 minutes)
**Visual:** UI development with live coding

**Narrator:**
"Now let's create a beautiful and intuitive trading interface that allows players to see their collected coins and perform trades. The UI will integrate seamlessly with our game and provide real-time market data."

**Implementation:**

```dart
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
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Crypto Collector',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coins: ${game.coinsCollected.toStringAsFixed(2)} ${game.currentCoin}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
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
        ),
        child: Text(
          coin,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
```

---

### Game UI and HUD (3 minutes)
**Visual:** HUD implementation and game overlay

**Narrator:**
"Let's add a heads-up display that shows the player's current status, including their coin balance, current cryptocurrency, and real-time market prices."

**Implementation:**

```dart
class GameUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 20,
      left: 20,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Score: ${gameRef.coinsCollected.toStringAsFixed(0)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Current: ${gameRef.currentCoin}',
              style: const TextStyle(color: Colors.orange, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### Testing and Demo (2 minutes)
**Visual:** Live game demonstration

**Narrator:**
"Now let's test our game! You can see how the player moves around collecting coins, and when they have enough, they can trade them for different cryptocurrencies using the Komodo DeFi SDK. The trading happens in real-time on the blockchain!"

**Demo Points:**
- Player movement and coin collection
- Real-time trading interface
- Market data integration
- Transaction confirmation
- Error handling

---

### Advanced Features and Customization (2 minutes)
**Visual:** Code snippets and feature demonstrations

**Narrator:**
"The beauty of this setup is its extensibility. You can easily add more features like multiple levels, different trading pairs, NFT integration, or even multiplayer functionality."

**Advanced Features to Mention:**
- Multiple trading pairs
- Price charts and analytics
- NFT integration
- Multiplayer trading
- Custom game mechanics
- Advanced DeFi protocols

---

### Conclusion and Next Steps (1 minute)
**Visual:** Summary slide with key takeaways

**Narrator:**
"In just 30 minutes, we've built a fully functional 2D game with real DeFi integration using Flame and the Komodo DeFi SDK. This demonstrates the power and simplicity of the Komodo ecosystem for game developers.

The Komodo DeFi SDK abstracts away the complexity of blockchain interactions, allowing you to focus on creating engaging gaming experiences. Whether you're building a trading game, an NFT marketplace, or any DeFi application, the SDK provides the tools you need to succeed.

To get started with your own projects, check out the Komodo DeFi SDK documentation and join our developer community. Happy coding!"

**Call to Action:**
- Visit Komodo DeFi SDK documentation
- Join developer community
- Share your creations
- Explore more advanced features

---

## Technical Notes for Video Production

### Visual Elements Needed:
1. Code editor with syntax highlighting
2. Game preview window
3. Terminal/console output
4. UI mockups and wireframes
5. Komodo DeFi SDK logo and branding
6. Flame game engine logo
7. Progress indicators and timers

### Audio Requirements:
- Clear narration with technical terminology
- Background music (optional, gaming-themed)
- Sound effects for game interactions
- Audio cues for code completion

### Interactive Elements:
- Live coding demonstrations
- Real-time game testing
- Error handling scenarios
- Success/failure animations

### Key Messages to Convey:
1. **Simplicity:** Komodo SDK makes DeFi integration easy
2. **Power:** Real blockchain functionality in games
3. **Flexibility:** Extensible architecture for various use cases
4. **Performance:** Efficient and reliable DeFi operations
5. **Community:** Strong developer ecosystem and support

### Target Metrics:
- Viewer engagement throughout the tutorial
- Code completion rate
- Questions and comments about SDK features
- Developer sign-ups and project starts