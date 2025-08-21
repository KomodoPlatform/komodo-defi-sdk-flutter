import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

import '../../../lib/migrations/bloc/migration_bloc.dart';
import '../../../lib/migrations/bloc/migration_event.dart';
import '../../../lib/migrations/bloc/migration_state.dart';
import '../../../lib/migrations/widgets/migration_screen.dart';

// Mock classes
class MockMigrationBloc extends MockBloc<MigrationEvent, MigrationState>
    implements MigrationBloc {}

void main() {
  group('MigrationScreen', () {
    late MockMigrationBloc mockBloc;

    setUp(() {
      mockBloc = MockMigrationBloc();
      when(() => mockBloc.state).thenReturn(const MigrationInitial());
    });

    tearDown(() {
      reset(mockBloc);
    });

    Widget createWidgetUnderTest({
      String title = 'Wallet Migration',
      bool showAppBar = true,
      Color? backgroundColor,
    }) {
      return MaterialApp(
        home: BlocProvider<MigrationBloc>.value(
          value: mockBloc,
          child: MigrationScreen(
            title: title,
            showAppBar: showAppBar,
            backgroundColor: backgroundColor,
          ),
        ),
      );
    }

    testWidgets('should display app bar with correct title when showAppBar is true', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(title: 'Test Migration'));

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Test Migration'), findsOneWidget);
    });

    testWidgets('should not display app bar when showAppBar is false', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(showAppBar: false));

      expect(find.byType(AppBar), findsNothing);
    });

    testWidgets('should trigger InitializeMigration event on init', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      verify(() => mockBloc.add(const InitializeMigration())).called(1);
    });

    testWidgets('should display loading widget for initial state', (tester) async {
      when(() => mockBloc.state).thenReturn(const MigrationInitial());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Initializing migration...'), findsOneWidget);
      expect(find.byIcon(Icons.sync), findsOneWidget);
    });

    testWidgets('should display loading widget with progress for loading state', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const MigrationLoading(
          message: 'Loading wallets...',
          progress: 0.5,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Loading wallets...'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('should display wallet selection for wallet selection state', (tester) async {
      final mockWallets = [
        WalletInfo(
          walletId: WalletId(id: 'test_wallet'),
          walletName: 'Test Wallet',
          walletType: 'iguana',
          isSupported: true,
        ),
      ];

      when(() => mockBloc.state).thenReturn(
        MigrationWalletSelection(availableWallets: mockWallets),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Select Wallets'), findsOneWidget);
      expect(find.text('Choose the source wallet to migrate from and the destination wallet to migrate to.'), findsOneWidget);
    });

    testWidgets('should display asset selection for asset selection state', (tester) async {
      final mockAssets = [
        AssetInfo(
          assetId: const AssetId(id: 'BTC'),
          name: 'Bitcoin',
          symbol: 'BTC',
          balance: Decimal.parse('1.0'),
          isActivated: true,
        ),
      ];

      const mockWallet = WalletInfo(
        walletId: WalletId(id: 'source'),
        walletName: 'Source Wallet',
        walletType: 'iguana',
        isSupported: true,
      );

      const targetWallet = WalletInfo(
        walletId: WalletId(id: 'target'),
        walletName: 'Target Wallet',
        walletType: 'hd',
        isSupported: true,
      );

      when(() => mockBloc.state).thenReturn(
        MigrationAssetSelection(
          sourceWallet: mockWallet,
          targetWallet: targetWallet,
          availableAssets: mockAssets,
          selectedAssets: const {},
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Select Assets'), findsOneWidget);
      expect(find.text('Source Wallet'), findsOneWidget);
      expect(find.text('Target Wallet'), findsOneWidget);
    });

    testWidgets('should display migration preview for preview ready state', (tester) async {
      final mockPreview = MigrationOperationPreview(
        previewId: 'test-preview',
        sourceWallet: const WalletId(id: 'source'),
        targetWallet: const WalletId(id: 'target'),
        assetPreviews: [],
        summary: MigrationSummary(
          totalAssets: 0,
          readyAssets: 0,
          assetsWithIssues: 0,
          totalEstimatedFees: Decimal.zero,
          totalNetAmount: Decimal.zero,
        ),
        createdAt: DateTime.now(),
      );

      when(() => mockBloc.state).thenReturn(
        MigrationPreviewReady(preview: mockPreview),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Migration Preview'), findsOneWidget);
    });

    testWidgets('should display migration progress for in progress state', (tester) async {
      when(() => mockBloc.state).thenReturn(
        MigrationInProgress(
          migrationId: 'test-migration',
          progress: MigrationProgress.initial('test-migration', []),
          assetProgresses: [],
          canCancel: true,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Migration in Progress'), findsOneWidget);
      expect(find.text('Please wait while your assets are being transferred...'), findsOneWidget);
    });

    testWidgets('should display migration complete for completed state', (tester) async {
      final mockResult = MigrationResult.successful(
        'test-migration',
        [],
        DateTime.now().subtract(const Duration(minutes: 5)),
      );

      when(() => mockBloc.state).thenReturn(
        MigrationCompleted(result: mockResult),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Migration Complete!'), findsOneWidget);
      expect(find.text('Your assets have been migrated to the destination wallet.'), findsOneWidget);
    });

    testWidgets('should show error dialog when error state is emitted', (tester) async {
      when(() => mockBloc.state).thenReturn(const MigrationInitial());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Simulate error state change
      when(() => mockBloc.state).thenReturn(
        const MigrationError(
          error: MigrationErrorType.networkError,
          message: 'Test error message',
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Migration Error'), findsOneWidget);
      expect(find.text('Network connection error. Please check your internet connection.'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('should animate between state transitions', (tester) async {
      when(() => mockBloc.state).thenReturn(const MigrationInitial());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(AnimatedSwitcher), findsOneWidget);
      expect(find.byType(SlideTransition), findsOneWidget);
    });

    testWidgets('should use custom background color when provided', (tester) async {
      const testColor = Colors.red;

      await tester.pumpWidget(createWidgetUnderTest(backgroundColor: testColor));
      await tester.pumpAndSettle();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(testColor));
    });

    testWidgets('should display loading animation with pulse effect', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const MigrationLoading(message: 'Processing...'),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Check for animated components
      expect(find.byType(AnimatedBuilder), findsWidgets);
      expect(find.byType(RotationTransition), findsOneWidget);
      expect(find.text('Please wait while we process your migration...'), findsOneWidget);
    });

    testWidgets('should handle null message in loading state', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const MigrationLoading(message: null),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.sync), findsOneWidget);
      expect(find.text('Please wait while we process your migration...'), findsOneWidget);
    });

    testWidgets('should display progress percentage when progress is provided', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const MigrationLoading(
          message: 'Loading...',
          progress: 0.75,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('75%'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });

  group('MigrationScreen Error Handling', () {
    late MockMigrationBloc mockBloc;

    setUp(() {
      mockBloc = MockMigrationBloc();
    });

    testWidgets('should handle error state gracefully', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const MigrationError(
          error: MigrationErrorType.networkError,
          message: 'Network connection failed',
          canRetry: true,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<MigrationBloc>.value(
            value: mockBloc,
            child: const MigrationScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Migration Error'), findsOneWidget);
      expect(find.text('Network connection error. Please check your internet connection.'), findsOneWidget);
    });

    testWidgets('should close error dialog when OK is tapped', (tester) async {
      when(() => mockBloc.state).thenReturn(const MigrationInitial());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<MigrationBloc>.value(
            value: mockBloc,
            child: const MigrationScreen(),
          ),
        ),
      );

      // Trigger error dialog
      when(() => mockBloc.state).thenReturn(
        const MigrationError(
          error: MigrationErrorType.networkError,
          message: 'Test error',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<MigrationBloc>.value(
            value: mockBloc,
            child: const MigrationScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap OK button
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Dialog should be closed
      expect(find.text('Migration Error'), findsNothing);
    });
  });
}
