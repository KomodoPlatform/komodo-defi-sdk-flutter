import kdf from './kdflib_bootstrapper.js';

function logCallback(level, message) {
  postMessage({ type: 'log', level, message });
}

self.onmessage = async (event) => {
  const { id, method, params } = event.data;
  try {
    let result;
    switch (method) {
      case 'init_wasm':
        await kdf.init_wasm();
        result = true;
        break;
      case 'mm2_main':
        result = await kdf.mm2_main(params.conf, logCallback, params.log_level);
        break;
      case 'mm2_main_status':
        result = kdf.mm2_main_status();
        break;
      case 'mm2_stop':
        result = await kdf.mm2_stop();
        break;
      case 'mm2_rpc':
        result = await kdf.mm2_rpc(params);
        break;
      default:
        throw new Error('Unknown method ' + method);
    }
    postMessage({ id, result });
  } catch (error) {
    postMessage({ id, error: error.toString() });
  }
};
