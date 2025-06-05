#ifndef KOMODO_DEFI_FRAMEWORK_H
#define KOMODO_DEFI_FRAMEWORK_H

#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

#ifdef _WIN32
#define FFI_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FFI_PLUGIN_EXPORT
#endif

typedef void (*LogCallback)(const char *line);

/**
 * Starts the MM2 in a detached singleton thread.
 */
// FFI_PLUGIN_EXPORT int8_t mm2_main(const char *conf, LogCallback log_cb);

FFI_PLUGIN_EXPORT int8_t mm2_main(const char *conf, LogCallback log_cb);

/**
 * Checks if the MM2 singleton thread is currently running or not.
 * 0 .. not running.
 * 1 .. running, but no context yet.
 * 2 .. context, but no RPC yet.
 * 3 .. RPC is up.
 */
FFI_PLUGIN_EXPORT int8_t mm2_main_status(void);

/**
 * Run a few hand-picked tests.
 *
 * The tests are wrapped into a library method in order to run them in such embedded environments
 * where running "cargo test" is not an easy option.
 *
 * MM2 is mostly used as a library in environments where we can't simpy run it as a separate process
 * and we can't spawn multiple MM2 instances in the same process YET
 * therefore our usual process-spawning tests can not be used here.
 *
 * Returns the `torch` (as in Olympic flame torch) if the tests have passed. Panics otherwise.
 */
FFI_PLUGIN_EXPORT int32_t mm2_test(int32_t torch, LogCallback log_cb);

/**
 * Stop an MM2 instance or reset the static variables.
 */
FFI_PLUGIN_EXPORT int8_t mm2_stop(void);

// FFI_PLUGIN_EXPORT const char *documentDirectory(void);
// FFI_PLUGIN_EXPORT int8_t mm2_main_status(void);
// FFI_PLUGIN_EXPORT uint8_t is_loopback_ip(const char *ip);
// FFI_PLUGIN_EXPORT int8_t mm2_main(const char *conf, void (*log_cb)(const char *line));
// FFI_PLUGIN_EXPORT int8_t mm2_stop(void);
// FFI_PLUGIN_EXPORT void lsof(void);
// FFI_PLUGIN_EXPORT const char *metrics(void);

// FFI_PLUGIN_EXPORT const char *mm2_version(void);
// FFI_PLUGIN_EXPORT const char *mm2_rpc(const char *request);
// FFI_PLUGIN_EXPORT void mm2_rpc_free(char *response);

#endif // KOMODO_DEFI_FRAMEWORK_H