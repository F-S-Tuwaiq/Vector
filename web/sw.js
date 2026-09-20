// Minimal app-shell service worker. Flutter's own generated service worker
// (flutter_service_worker.js) is no longer auto-registered by
// flutter_bootstrap.js as of recent Flutter versions (it's deprecated
// upstream), so this hand-rolled one takes its place: it caches the shell
// files needed to reopen the app offline/on a flaky connection and is the
// fetch-handling service worker Chrome requires before it will offer
// "Install app" / add-to-home-screen.
const CACHE_NAME = 'vector-shell-v1';
const SHELL_ASSETS = [
  './',
  'index.html',
  'main.dart.js',
  'flutter.js',
  'flutter_bootstrap.js',
  'manifest.json',
  'favicon.png',
  'icons/Icon-192.png',
  'icons/Icon-512.png',
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches
      .open(CACHE_NAME)
      .then((cache) => cache.addAll(SHELL_ASSETS))
      .catch(() => {}),
  );
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches
      .keys()
      .then((keys) =>
        Promise.all(keys.filter((key) => key !== CACHE_NAME).map((key) => caches.delete(key))),
      )
      .then(() => self.clients.claim()),
  );
});

self.addEventListener('fetch', (event) => {
  if (event.request.method !== 'GET') return;
  event.respondWith(
    caches.match(event.request).then((cached) => cached || fetch(event.request)),
  );
});
