import 'package:dragon_logs/src/storage/log_storage.dart';
import 'package:dragon_logs/src/storage/web_log_storage.dart';

LogStorage getLogStorageInstance() => WebLogStorage();
