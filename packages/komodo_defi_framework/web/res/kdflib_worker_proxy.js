const worker = new Worker(new URL('./kdflib_worker.js', import.meta.url), { type: 'module' });

let counter = 0;
const pending = new Map();

worker.onmessage = (event) => {
  const { id, result, error, type, level, message } = event.data;
  if (type === 'log') {
    if (kdf._logHandler) kdf._logHandler(level, message);
    return;
  }
  const cb = pending.get(id);
  if (cb) {
    pending.delete(id);
    if (error) cb.reject(error); else cb.resolve(result);
  }
};

function callWorker(method, params) {
  return new Promise((resolve, reject) => {
    const id = ++counter;
    pending.set(id, { resolve, reject });
    worker.postMessage({ id, method, params });
  });
}

export function setLogHandler(handler) {
  kdf._logHandler = handler;
}

export async function init_wasm() {
  return callWorker('init_wasm');
}

export async function mm2_main(conf, log_level) {
  return callWorker('mm2_main', { conf, log_level });
}

export function mm2_main_status() {
  return callWorker('mm2_main_status');
}

export async function mm2_stop() {
  return callWorker('mm2_stop');
}

export async function mm2_rpc(request) {
  return callWorker('mm2_rpc', request);
}

const kdf = {
  init_wasm,
  mm2_main,
  mm2_main_status,
  mm2_stop,
  mm2_rpc,
  setLogHandler,
  _logHandler: null,
};

export default kdf;
export { kdf };
