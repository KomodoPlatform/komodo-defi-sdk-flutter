/// Utility functions for the Migration BLoC
class MigrationBlocUtils {
  MigrationBlocUtils._();

  /// Helper to generate unique IDs for migration operations
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Helper to format duration for display
  static String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Helper to calculate progress percentage
  static double calculateProgress(int completed, int total) {
    if (total == 0) return 0.0;
    return (completed / total).clamp(0.0, 1.0);
  }

  /// Helper to format coin amounts for display
  static String formatCoinAmount(String amount, String symbol) {
    try {
      final parts = amount.split(' ');
      if (parts.length >= 2) {
        final numericPart = double.parse(parts[0]);
        return '${numericPart.toStringAsFixed(6)} ${parts[1]}';
      }
      return amount;
    } catch (e) {
      return amount;
    }
  }

  /// Helper to determine if migration should show retry option
  static bool shouldShowRetry(String? errorMessage) {
    if (errorMessage == null) return false;

    final retryableErrors = [
      'network error',
      'timeout',
      'connection failed',
      'temporary',
    ];

    final lowerError = errorMessage.toLowerCase();
    return retryableErrors.any((error) => lowerError.contains(error));
  }

  /// Helper to get user-friendly error message
  static String getUserFriendlyErrorMessage(String? errorMessage) {
    if (errorMessage == null || errorMessage.isEmpty) {
      return 'Unknown error occurred';
    }

    final lowerError = errorMessage.toLowerCase();

    if (lowerError.contains('network') || lowerError.contains('connection')) {
      return 'Network connection error. Please check your internet connection.';
    } else if (lowerError.contains('timeout')) {
      return 'Operation timed out. Please try again.';
    } else if (lowerError.contains('balance') && lowerError.contains('low')) {
      return 'Insufficient balance to cover network fees.';
    } else if (lowerError.contains('fee')) {
      return 'Transaction fee estimation failed.';
    } else if (lowerError.contains('locked')) {
      return 'Wallet is locked. Please unlock and try again.';
    }

    return errorMessage;
  }

  /// Helper to determine coin display order
  static int compareCoinsByPriority(String symbolA, String symbolB) {
    const priorityCoins = ['KMD', 'BTC', 'LTC', 'ETH', 'USDC'];

    final priorityA = priorityCoins.indexOf(symbolA);
    final priorityB = priorityCoins.indexOf(symbolB);

    if (priorityA != -1 && priorityB != -1) {
      return priorityA.compareTo(priorityB);
    } else if (priorityA != -1) {
      return -1; // A has priority
    } else if (priorityB != -1) {
      return 1; // B has priority
    }

    // Neither has priority, sort alphabetically
    return symbolA.compareTo(symbolB);
  }

  /// Helper to validate migration requirements
  static List<String> validateMigrationRequirements({
    String? sourceWallet,
    String? targetWallet,
    int coinCount = 0,
  }) {
    final errors = <String>[];

    if (sourceWallet == null || sourceWallet.isEmpty) {
      errors.add('Source wallet is required');
    }

    if (targetWallet == null || targetWallet.isEmpty) {
      errors.add('Target wallet is required');
    }

    if (sourceWallet == targetWallet) {
      errors.add('Source and target wallets cannot be the same');
    }

    if (coinCount == 0) {
      errors.add('At least one coin must be available for migration');
    }

    return errors;
  }

  /// Helper to get migration status display text
  static String getStatusDisplayText(String status) {
    switch (status.toLowerCase()) {
      case 'idle':
        return 'Ready to start';
      case 'scanning':
        return 'Scanning for coins...';
      case 'preview':
        return 'Review migration details';
      case 'transferring':
        return 'Transferring coins...';
      case 'completed':
        return 'Migration completed';
      case 'error':
        return 'Migration failed';
      default:
        return status;
    }
  }

  /// Helper to truncate transaction hash for display
  static String truncateTransactionHash(String txHash, {int prefixLength = 8, int suffixLength = 8}) {
    if (txHash.length <= prefixLength + suffixLength + 3) {
      return txHash;
    }

    return '${txHash.substring(0, prefixLength)}...${txHash.substring(txHash.length - suffixLength)}';
  }

  /// Helper to generate explorer URL for transaction
  static String? getExplorerUrl(String coinSymbol, String txHash) {
    // This is a mock implementation
    // In reality, this would return the appropriate explorer URL for each coin
    switch (coinSymbol.toUpperCase()) {
      case 'BTC':
        return 'https://blockstream.info/tx/$txHash';
      case 'LTC':
        return 'https://litecoinblockexplorer.net/tx/$txHash';
      case 'KMD':
        return 'https://kmdexplorer.io/tx/$txHash';
      default:
        return null;
    }
  }

  /// Helper to determine if coin supports migration
  static bool isCoinMigrationSupported(String coinSymbol) {
    // List of coins that support migration
    const supportedCoins = [
      'KMD', 'BTC', 'LTC', 'DOGE', 'BCH', 'ZEC', 'DASH',
      'DGB', 'RVN', 'GRS', 'VTC', 'FIRO', 'QTUM'
    ];

    return supportedCoins.contains(coinSymbol.toUpperCase());
  }
}
