import 'package:komodo_defi_rpc_methods/src/rpc_methods/trading/trade_preimage.dart';
import 'package:test/test.dart';

void main() {
  group('MM2 rational encoding', () {
    test('PreimageCoinFee amount_rat round-trip preserves limbs', () {
      final srcAmountRat = [
        [
          1,
          [1792496569, 37583],
        ],
        [
          1,
          [2808348672, 232830643],
        ],
      ];

      final fee = PreimageCoinFee.fromJson({
        'coin': 'KMD',
        'amount': '1.234',
        'amount_fraction': {'numer': '1234', 'denom': '1000'},
        'amount_rat': srcAmountRat,
        'paid_from_trading_vol': false,
      });

      final out = fee.toJson();
      expect(out['amount_rat'], equals(srcAmountRat));
    });

    test('PreimageTotalFee amount_rat and required_balance_rat round-trip', () {
      final amountRat = [
        [
          -1,
          [5],
        ],
        [
          1,
          [2],
        ],
      ];
      final reqBalRat = [
        [
          1,
          [1, 0, 0],
        ],
        [
          1,
          [10],
        ],
      ];

      final total = PreimageTotalFee.fromJson({
        'coin': 'BTC',
        'amount': '0.1',
        'amount_fraction': {'numer': '1', 'denom': '10'},
        'amount_rat': amountRat,
        'required_balance': '0.1',
        'required_balance_fraction': {'numer': '1', 'denom': '10'},
        'required_balance_rat': reqBalRat,
      });

      final out = total.toJson();
      // amount_rat has no trailing zero limbs so exact match is expected
      expect(out['amount_rat'], equals(amountRat));
      // required_balance_rat may be normalized (trailing zero limbs removed)
      final reparsed = PreimageTotalFee.fromJson({
        'coin': 'BTC',
        'amount': '0.1',
        'amount_fraction': {'numer': '1', 'denom': '10'},
        'amount_rat': out['amount_rat'],
        'required_balance': '0.1',
        'required_balance_fraction': {'numer': '1', 'denom': '10'},
        'required_balance_rat': out['required_balance_rat'],
      });
      expect(reparsed.requiredBalanceRat, equals(total.requiredBalanceRat));
    });
  });
}
