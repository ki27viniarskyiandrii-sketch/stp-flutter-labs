// Віддає веб-збірку і пересилає запити Storage (/v0/...) в емулятор.
// Сторінка і емулятор мають одну адресу, тому Codespaces пропускає запити
// з тими ж cookie, що і саму сторінку.
const http = require('http');
const fs = require('fs');
const path = require('path');

const ROOT = path.join(__dirname, '..', 'build', 'web');
const EMU = { host: '127.0.0.1', port: 9199 };
const PORT = Number(process.env.PORT || 8083);
const TYPES = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript',
  '.mjs': 'text/javascript',
  '.json': 'application/json',
  '.wasm': 'application/wasm',
  '.png': 'image/png',
  '.ico': 'image/x-icon',
  '.svg': 'image/svg+xml',
  '.otf': 'font/otf',
  '.ttf': 'font/ttf',
  '.css': 'text/css',
};

http.createServer((req, res) => {
  if (req.url.startsWith('/v0/')) return proxy(req, res);
  let file = path.join(ROOT, decodeURIComponent(req.url.split('?')[0]));
  if (!file.startsWith(ROOT)) {
    res.writeHead(403);
    return res.end();
  }
  if (fs.existsSync(file) && fs.statSync(file).isDirectory()) file = path.join(file, 'index.html');
  fs.readFile(file, (err, data) => {
    if (err) {
      res.writeHead(404);
      return res.end('not found');
    }
    res.writeHead(200, {
      'Content-Type': TYPES[path.extname(file)] || 'application/octet-stream',
      'Cache-Control': 'no-cache',
    });
    res.end(data);
  });
}).listen(PORT, () => console.log(`static + storage proxy on ${PORT}`));

function proxy(req, res) {
  const publicHost = req.headers['x-forwarded-host'] || req.headers.host;
  const upstream = http.request(
    { ...EMU, method: req.method, path: req.url, headers: { ...req.headers, host: `${EMU.host}:${EMU.port}` } },
    (r) => {
      const headers = { ...r.headers };
      // емулятор дає адреси виду http://127.0.0.1:9199/..., міняю на адресу сторінки
      for (const k of ['x-goog-upload-url', 'location']) {
        if (headers[k]) {
          headers[k] = headers[k].replace(/https?:\/\/(127\.0\.0\.1|localhost|0\.0\.0\.0):9199/, `https://${publicHost}`);
        }
      }
      res.writeHead(r.statusCode, headers);
      r.pipe(res);
    },
  );
  upstream.on('error', (e) => {
    res.writeHead(502);
    res.end(`storage emulator: ${e.message}`);
  });
  req.pipe(upstream);
}
