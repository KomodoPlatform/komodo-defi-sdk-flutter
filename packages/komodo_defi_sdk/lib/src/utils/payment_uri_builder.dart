import 'package:decimal/decimal.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class PaymentUriBuilder {
  static String forAsset({
    required Asset asset,
    required String address,
    required Decimal amount,
    String? label,
    String? message,
  }) {
    final subclass = asset.id.subClass;
    if (subclass == CoinSubClass.utxo || subclass == CoinSubClass.smartChain) {
      final scheme = _schemeForUtxo(asset);
      final amt = _formatAmount(amount, asset);
      final params = <String, String>{'amount': amt};
      if (label != null && label.isNotEmpty) params['label'] = label;
      if (message != null && message.isNotEmpty) params['message'] = message;
      final query = params.entries
          .map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
          .join('&');
      return '$scheme:$address?$query';
    }

    if (evmCoinSubClasses.contains(subclass)) {
      // Basic EIP-681: ethereum:<address>?value=<wei>
      final wei = _toWei(amount, asset);
      return 'ethereum:$address?value=$wei';
    }

    // Fallback: just the address. UI can still display amount separately.
    return address;
  }

  static String _schemeForUtxo(Asset asset) {
    final ticker = asset.id.symbol.ticker.toLowerCase();
    // Some coins may want custom schemes; default to ticker
    return ticker;
  }

  static String _formatAmount(Decimal amount, Asset asset) {
    final decimals = asset.id.chainId.decimals ?? 8;
    // Use toStringAsFixed via Decimal toString() by scaling
    final scale = Decimal.fromInt(10).pow(decimals);
    final scaled = (amount * scale).toBigInt().toString();
    final padded = scaled.padLeft(decimals + 1, '0');
    final whole = padded.substring(0, padded.length - decimals);
    final frac = padded.substring(padded.length - decimals).replaceFirst(RegExp(r'0+$'), '');
    return frac.isEmpty ? whole : '$whole.$frac';
  }

  static String _toWei(Decimal amount, Asset asset) {
    final decimals = asset.id.chainId.decimals ?? 18;
    final scale = Decimal.fromInt(10).pow(decimals);
    final wei = (amount * scale).toBigInt();
    return wei.toString();
  }
}

