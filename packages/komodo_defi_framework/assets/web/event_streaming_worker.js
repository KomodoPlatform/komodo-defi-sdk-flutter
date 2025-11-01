// SharedWorker script that forwards messages to all connected ports.
/* eslint-disable no-restricted-globals */

const connections = [];

onconnect = function (e) {
  const port = e.ports[0];
  connections.push(port);
  port.start();

  port.onmessage = function (msgEvent) {
    try {
      const data = msgEvent.data;
      for (const p of connections) {
        try { p.postMessage(data); } catch (_) { }
      }
    } catch (_) { }
  };
};
