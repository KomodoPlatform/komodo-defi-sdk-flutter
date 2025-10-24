#import <Foundation/Foundation.h>
#include <signal.h>

// Install a process-wide SIGPIPE ignore as early as possible when the plugin
// is loaded. This prevents the app from being terminated by broken pipe
// errors coming from native networking/FFI layers.
__attribute__((constructor)) static void KDFInstallSigpipeHandler(void) {
  signal(SIGPIPE, SIG_IGN);
}
