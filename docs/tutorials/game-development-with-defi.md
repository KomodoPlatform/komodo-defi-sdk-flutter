# Building a 2D Game with Flame and Komodo DeFi SDK: Tutorial Script

**Duration:** 30 minutes  
**Target Audience:** Game developers interested in integrating DeFi functionality  
**Objective:** Demonstrate how to create a simple 2D game using Flame and Komodo DeFi SDK with basic swap trading functionality

---

## Tutorial Overview

This tutorial shows game developers how to build "Crypto Trader's Quest" - a simple 2D trading game where players collect coins, manage a wallet, and perform real cryptocurrency swaps to progress through levels. The game demonstrates the power of the Komodo DeFi SDK for creating engaging GameFi experiences.

### What You'll Learn
- Setting up a Flame game with Komodo DeFi SDK integration
- Implementing wallet functionality within a game context
- Adding real cryptocurrency trading as a game mechanic
- Creating engaging user experiences that drive adoption
- Monetization opportunities through DeFi integration

### What You'll Build
A complete 2D game featuring:
- Player character that collects in-game tokens
- Real wallet integration for managing cryptocurrencies
- Trading mechanics using actual swap functionality
- Progressive gameplay tied to DeFi activities
- Professional UI/UX that game developers expect

---

## Tutorial Script

### Introduction (0:00 - 3:00)

**[Scene: Welcome screen with tutorial title]**

"Welcome to this tutorial on building 2D games with Flame and the Komodo DeFi SDK. I'm going to show you how to create 'Crypto Trader's Quest' - a game that seamlessly integrates real cryptocurrency trading as a core gameplay mechanic.

**Why should game developers care about DeFi integration?**

Traditional games rely on in-app purchases and ads for monetization. But what if your players could use real cryptocurrency, trade actual tokens, and even earn money while playing? That's the power of GameFi - and the Komodo DeFi SDK makes it incredibly simple to implement.

**What makes Komodo DeFi special for game developers?**

- **Cross-chain compatibility**: Support for Bitcoin, Ethereum, and 60+ blockchains
- **No custodial wallets needed**: Players control their own assets
- **Atomic swaps**: Direct peer-to-peer trading without intermediaries
- **Flutter-native**: Perfect integration with Flutter/Dart ecosystem
- **Minimal setup**: What used to take months now takes days

Let's dive in and build something amazing!"

### Setting Up the Project (3:00 - 8:00)

**[Scene: IDE with terminal/code editor]**

"First, let's set up our project. I'm starting with the existing dex_dungeon game from the Komodo DeFi SDK repository, but I'll show you how to add these features to any Flame game.

**Step 1: Project Setup**

```bash
# Clone the repository
git clone https://github.com/KomodoPlatform/komodo-defi-sdk-flutter
cd komodo-defi-sdk-flutter/products/dex_dungeon

# Check dependencies
cat pubspec.yaml
```

Notice how clean this is - we have Flame for the game engine and komodo_defi_sdk for DeFi functionality. That's all we need!

**Step 2: Understanding the Architecture**

Let me show you the existing game structure:

```dart
// lib/game/dex_dungeon.dart
class DexDungeon extends FlameGame {
  // Basic game setup with world and camera
  @override
  Future<void> onLoad() async {
    final world = World(children: [
      Player(position: size / 2),
      TradingPost(position: Vector2(size.x * 0.8, size.y * 0.2)),
    ]);
    
    final camera = CameraComponent(world: world);
    await addAll([world, camera]);
  }
}
```

**Step 3: Adding DeFi Dependencies**

The game already includes the Komodo DeFi SDK, but let me show you what each dependency does:

- `flame`: 2D game engine for Flutter
- `komodo_defi_sdk`: High-level DeFi functionality
- `komodo_defi_types`: Type definitions for trading operations
- `flutter_bloc`: State management for complex DeFi operations

This combination gives us everything needed for a professional GameFi experience."

### Implementing Wallet Integration (8:00 - 15:00)

**[Scene: Code editor showing wallet implementation]**

"Now let's add real wallet functionality to our game. This is where it gets exciting - we're dealing with actual cryptocurrency!

**Step 1: Setting Up the DeFi SDK**

```dart
// lib/game/blocs/wallet_bloc.dart
class WalletBloc extends Bloc<WalletEvent, WalletState> {
  WalletBloc() : super(WalletInitial()) {
    on<InitializeWallet>(_onInitializeWallet);
    on<CreateWallet>(_onCreateWallet);
    on<LoadBalance>(_onLoadBalance);
  }

  late KomodoDefiSdk _sdk;

  Future<void> _onInitializeWallet(
    InitializeWallet event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());
    
    try {
      // Initialize SDK with configuration
      _sdk = KomodoDefiSdk(config: const KomodoDefiSdkConfig());
      await _sdk.initialize();
      
      emit(WalletReady());
    } catch (e) {
      emit(WalletError('Failed to initialize wallet: $e'));
    }
  }

  Future<void> _onCreateWallet(
    CreateWallet event,
    Emitter<WalletState> emit,
  ) async {
    try {
      // Create wallet with seed phrase
      final user = await _sdk.auth.createWallet(
        walletId: WalletId(name: 'GameWallet'),
        seedPhrase: event.seedPhrase,
        password: event.password,
      );
      
      emit(WalletAuthenticated(user: user));
    } catch (e) {
      emit(WalletError('Failed to create wallet: $e'));
    }
  }
}
```

**Step 2: Creating the Wallet UI Component**

```dart
// lib/game/components/wallet_widget.dart
class WalletWidget extends PositionComponent with HasGameRef<DexDungeon> {
  late final RectangleComponent background;
  late final TextComponent balanceText;
  late final ButtonComponent createWalletButton;
  
  @override
  Future<void> onLoad() async {
    // Create wallet UI overlay
    size = Vector2(200, 100);
    
    background = RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.black.withOpacity(0.8),
    );
    
    balanceText = TextComponent(
      text: 'No wallet connected',
      textRenderer: TextPaint(style: gameRef.textStyle),
      position: Vector2(10, 20),
    );
    
    createWalletButton = ButtonComponent(
      button: RectangleComponent(
        size: Vector2(180, 30),
        paint: Paint()..color = Colors.blue,
      ),
      buttonDown: RectangleComponent(
        size: Vector2(180, 30),
        paint: Paint()..color = Colors.blue.shade700,
      ),
      onPressed: _showWalletCreation,
      position: Vector2(10, 50),
    );
    
    await addAll([background, balanceText, createWalletButton]);
  }
  
  void _showWalletCreation() {
    // Show wallet creation dialog
    gameRef.showWalletCreationDialog();
  }
}
```

**Step 3: Integrating with Game State**

Notice how we're not just adding DeFi as an afterthought - it's integrated into the core game mechanics. The wallet becomes part of the game's UI, and the player's cryptocurrency balance affects their gameplay options.

This is the key to successful GameFi: make the DeFi functionality feel natural and essential to the game experience, not like a separate add-on."

### Adding Trading Mechanics (15:00 - 23:00)

**[Scene: Game running with trading interface]**

"Now comes the most exciting part - implementing actual cryptocurrency trading as a game mechanic! 

**Step 1: Creating the Trading System**

```dart
// lib/game/components/trading_post.dart
class TradingPost extends PositionComponent 
    with HasGameRef<DexDungeon>, TapCallbacks {
  
  @override
  Future<void> onLoad() async {
    // Visual representation of trading post
    final sprite = await Sprite.load('trading_post.png');
    add(SpriteComponent(sprite: sprite, size: Vector2.all(64)));
    
    // Add interaction indicator
    add(CircleComponent(
      radius: 40,
      paint: Paint()..color = Colors.yellow.withOpacity(0.3),
      anchor: Anchor.center,
    ));
  }
  
  @override
  bool onTapDown(TapDownEvent event) {
    _openTradingInterface();
    return true;
  }
  
  void _openTradingInterface() {
    gameRef.showTradingDialog();
  }
}
```

**Step 2: Implementing Swap Functionality**

```dart
// lib/game/blocs/trading_bloc.dart
class TradingBloc extends Bloc<TradingEvent, TradingState> {
  TradingBloc({required this.sdk}) : super(TradingInitial()) {
    on<LoadTradingPairs>(_onLoadTradingPairs);
    on<ExecuteSwap>(_onExecuteSwap);
    on<GetSwapQuote>(_onGetSwapQuote);
  }

  final KomodoDefiSdk sdk;

  Future<void> _onGetSwapQuote(
    GetSwapQuote event,
    Emitter<TradingState> emit,
  ) async {
    try {
      emit(TradingLoading());
      
      // Get real-time swap quote
      final quote = await sdk.trading.getSwapQuote(
        from: event.fromAsset,
        to: event.toAsset,
        amount: event.amount,
      );
      
      emit(TradingQuoteReceived(quote: quote));
    } catch (e) {
      emit(TradingError('Failed to get quote: $e'));
    }
  }

  Future<void> _onExecuteSwap(
    ExecuteSwap event,
    Emitter<TradingState> emit,
  ) async {
    try {
      emit(TradingExecuting());
      
      // Execute actual atomic swap
      final result = await sdk.trading.executeSwap(
        quote: event.quote,
      );
      
      // Update game state based on successful trade
      emit(TradingSuccess(result: result));
      
      // Trigger game progression
      _updateGameProgress(result);
    } catch (e) {
      emit(TradingError('Swap failed: $e'));
    }
  }
  
  void _updateGameProgress(SwapResult result) {
    // Unlock new levels based on trading volume
    // Award achievements for successful trades
    // Update player's trading reputation
  }
}
```

**Step 3: Creating the Trading UI**

```dart
// lib/game/views/trading_dialog.dart
class TradingDialog extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 400,
        height: 500,
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text('Crypto Trading Post', 
                 style: Theme.of(context).textTheme.headlineSmall),
            
            // Asset selection
            Row(
              children: [
                Expanded(child: _buildAssetSelector('From')),
                Icon(Icons.swap_horiz),
                Expanded(child: _buildAssetSelector('To')),
              ],
            ),
            
            // Amount input
            TextField(
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            
            // Real-time quote display
            BlocBuilder<TradingBloc, TradingState>(
              builder: (context, state) {
                if (state is TradingQuoteReceived) {
                  return _buildQuoteDisplay(state.quote);
                }
                return SizedBox.shrink();
              },
            ),
            
            // Execute trade button
            ElevatedButton(
              onPressed: _executeTrade,
              child: Text('Execute Swap'),
            ),
          ],
        ),
      ),
    );
  }
}
```

**The Game-Changing Aspect**

What makes this special is that these aren't fake in-game currencies - these are real cryptocurrencies! When a player swaps Bitcoin for Ethereum in our game, they're performing an actual atomic swap on the blockchain.

This creates unprecedented opportunities:
- Players can earn real money through skilled trading
- Game progression tied to real-world financial literacy
- Cross-game economies where assets have actual value
- New monetization models beyond traditional IAP"

### Game Integration and User Experience (23:00 - 28:00)

**[Scene: Complete game running with all features]**

"Let's see how all these pieces come together to create a compelling gaming experience.

**Progressive Gameplay Design**

```dart
// lib/game/systems/progression_system.dart
class ProgressionSystem extends Component with HasGameRef<DexDungeon> {
  int tradingLevel = 1;
  double totalTradingVolume = 0.0;
  List<Achievement> unlockedAchievements = [];

  void onTradeCompleted(SwapResult result) {
    // Update trading statistics
    totalTradingVolume += result.fromAmount.toDouble();
    
    // Check for level progression
    if (totalTradingVolume > tradingLevel * 1000) {
      levelUp();
    }
    
    // Check achievements
    _checkTradingAchievements(result);
    
    // Unlock new trading pairs
    _unlockTradingPairs();
  }
  
  void levelUp() {
    tradingLevel++;
    gameRef.showLevelUpAnimation();
    
    // Unlock new game areas
    if (tradingLevel == 5) {
      gameRef.unlockAdvancedTradingPost();
    }
  }
}
```

**Real-World Integration**

The beauty of this approach is that game progression is tied to real DeFi skills:

1. **Learning Curve**: Players start with simple BTC/ETH swaps
2. **Skill Development**: Advanced players learn about arbitrage opportunities
3. **Risk Management**: Game teaches proper portfolio management
4. **Real Rewards**: Successful players earn actual cryptocurrency

**User Experience Considerations**

```dart
// lib/game/services/tutorial_service.dart
class TutorialService {
  static void showWalletIntroduction() {
    // Explain wallet security in game context
    // Show how to backup seed phrases safely
    // Demonstrate small test transactions first
  }
  
  static void showTradingBasics() {
    // Explain slippage and fees
    // Show how to read price charts
    // Practice with small amounts first
  }
}
```

This isn't just about adding crypto to games - it's about creating educational experiences that make DeFi accessible and fun."

### Monetization and Business Model (28:00 - 30:00)

**[Scene: Analytics dashboard showing potential revenue streams]**

"Finally, let's talk about why this matters for your business.

**Traditional Game Monetization vs. DeFi-Integrated Games**

Traditional:
- In-app purchases: $1-5 per user
- Ads: $0.10-0.50 per user per day
- Premium upgrades: One-time payments

DeFi-Integrated:
- Transaction fees: Small percentage of each trade
- Premium trading features: Recurring subscriptions
- Cross-game asset marketplaces: Platform fees
- Educational content: Premium tutorials and analysis

**Revenue Opportunities**

```dart
// Example revenue calculation
class RevenueProjection {
  static double calculatePotentialRevenue() {
    const double averageTradeSize = 100.0; // USD
    const double tradesPerUserPerDay = 2.0;
    const double feePercentage = 0.001; // 0.1%
    const int activeUsers = 10000;
    
    final dailyVolume = averageTradeSize * tradesPerUserPerDay * activeUsers;
    final dailyRevenue = dailyVolume * feePercentage;
    
    return dailyRevenue; // Potentially $200/day from 10k users
  }
}
```

**Player Retention Benefits**

DeFi integration creates unprecedented retention:
- Players have real money invested in the game
- Cross-game economies create network effects
- Educational value brings repeat engagement
- Community trading creates social bonds

**Getting Started Today**

1. Clone the repository: `git clone https://github.com/KomodoPlatform/komodo-defi-sdk-flutter`
2. Follow the setup guide in the README
3. Start with the dex_dungeon example
4. Join our Discord for developer support
5. Read the comprehensive documentation

**Conclusion**

The Komodo DeFi SDK transforms what's possible in game development. You're not just building games anymore - you're building the future of interactive finance.

With cross-chain support, atomic swaps, and Flutter-native integration, you can create GameFi experiences that were previously impossible or required massive blockchain development teams.

The future of gaming is here, and it's decentralized. Start building today!

Thank you for watching, and happy coding!"

---

## Tutorial Resources

### Code Repository
- Complete source code: [GitHub Repository](https://github.com/KomodoPlatform/komodo-defi-sdk-flutter)
- Live example: [Demo Application](https://komodo-playground.web.app)

### Documentation Links
- [Komodo DeFi SDK Documentation](https://docs.komodefi.com)
- [Flame Engine Documentation](https://docs.flame-engine.org)
- [Flutter GameDev Best Practices](https://flutter.dev/games)

### Community and Support
- Discord: [Komodo Developer Community](https://discord.gg/komodoplatform)
- GitHub Issues: [Report bugs and request features](https://github.com/KomodoPlatform/komodo-defi-sdk-flutter/issues)
- Developer Blog: [Latest updates and tutorials](https://blog.komodoplatform.com)

### Next Steps
1. Build the complete tutorial project
2. Experiment with different trading mechanisms
3. Explore advanced DeFi features like liquidity providing
4. Connect with other GameFi developers in the community
5. Consider participating in Komodo's developer grant program

---

*This tutorial demonstrates the power and simplicity of integrating real DeFi functionality into games using the Komodo DeFi SDK. The combination of Flame's robust game engine and Komodo's comprehensive blockchain integration creates unlimited possibilities for innovative GameFi experiences.*