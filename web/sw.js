// Minimal app-shell service worker. Flutter's own generated service worker
// (flutter_service_worker.js) is no longer auto-registered by
// flutter_bootstrap.js as of recent Flutter versions (it's deprecated
// upstream), so this hand-rolled one takes its place: it's the
// fetch-handling service worker Chrome requires before it will offer
// "Install app" / add-to-home-screen, and it gives the shell an offline
// fallback.
//
// Network-first, not cache-first: this app ships new builds to the same
// URL often, and a cache-first shell would silently freeze returning
// visitors on whatever version happened to be cached on their first
// visit, even across many redeploys, since the browser only reinstalls
// this worker when this file's bytes change. Always prefer the network
// when it's available; only fall back to the cache when it's not.
const CACHE_NAME = 'vector-shell-v2';
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
    fetch(event.request)
      .then((response) => {
        const copy = response.clone();
        caches.open(CACHE_NAME).then((cache) => cache.put(event.request, copy));
        return response;
      })
      .catch(() => caches.match(event.request)),
  );
});
