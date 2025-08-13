import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_defi_framework/src/js/js_result_mappers.dart';
import 'package:komodo_defi_framework/src/operations/kdf_operations_interface.dart';

void main() {
  group('mapJsStopResult', () {
    test('numeric codes', () {
      expect(mapJsStopResult(0), StopStatus.ok);
      expect(mapJsStopResult(1), StopStatus.notRunning);
      expect(mapJsStopResult(2), StopStatus.errorStopping);
      expect(mapJsStopResult(3), StopStatus.stoppingAlready);
      expect(mapJsStopResult(3.0), StopStatus.stoppingAlready);
    });

    test('string responses', () {
      expect(mapJsStopResult('success'), StopStatus.ok);
      expect(mapJsStopResult('ok'), StopStatus.ok);
      expect(mapJsStopResult('already_stopped'), StopStatus.stoppingAlready);
      expect(mapJsStopResult('Already stopped'), StopStatus.stoppingAlready);
      expect(mapJsStopResult('2'), StopStatus.errorStopping);
      expect(mapJsStopResult('unexpected'), StopStatus.ok);
    });

    test('map responses', () {
      expect(mapJsStopResult({'error': 'Something'}), StopStatus.errorStopping);
      expect(mapJsStopResult({'result': 'success'}), StopStatus.ok);
      expect(mapJsStopResult({'result': 0}), StopStatus.ok);
      expect(mapJsStopResult({'code': 3}), StopStatus.stoppingAlready);
      expect(mapJsStopResult({'unexpected': true}), StopStatus.ok);
    });

    test('null treated as ok', () {
      expect(mapJsStopResult(null), StopStatus.ok);
    });
  });
}
