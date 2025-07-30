import 'package:flutter/widgets.dart';

mixin LifecycleManagedMixin on WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      onDispose();
    }
  }

  void onDispose();

  void initLifecycleManagement() {
    WidgetsBinding.instance.addObserver(this);
  }

  void disposeLifecycleManagement() {
    WidgetsBinding.instance.removeObserver(this);
  }
}
