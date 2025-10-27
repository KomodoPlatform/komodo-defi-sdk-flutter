typedef SharedWorkerUnsubscribe = void Function();

SharedWorkerUnsubscribe connectSharedWorker(
  void Function(Object? data) onMessage,
) {
  // No-op on non-web platforms
  return () {};
}


