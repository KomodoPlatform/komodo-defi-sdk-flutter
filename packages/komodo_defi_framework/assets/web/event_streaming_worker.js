// SharedWorker script that forwards messages to all connected ports.
/* eslint-disable no-restricted-globals */

const connections = [];

onconnect = function (e) {
  const port = e.ports[0];
  connections.push(port);
  port.start();

  port.addEventListener('close', () => {
    const index = connections.indexOf(port);
    if (index > -1) {
      connections.splice(index, 1);
    }
  });

  port.onmessage = function (msgEvent) {
    try {
      const data = msgEvent.data;
      for (const p of connections) {
        try {
          p.postMessage(data);
        } catch (err) {
          console.error('[SharedWorker] Failed to forward message:', err);
        }
      }
    } catch (err) {
      console.error('[SharedWorker] Message handling error:', err);
    }
  };
};
