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
const CACHE_NAME = 'vector-shell-v3';
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
        Promise.all(keys.filter((key) => key.startsWith('vector-shell-') && key !== CACHE_NAME).map((key) => caches.delete(key))),
      )
      .then(() => self.clients.claim()),
  );
});

self.addEventListener('fetch', (event) => {
  if (event.request.method !== 'GET') return;
  const url = new URL(event.request.url);
  // Never cache Supabase responses, signed uploads, or other external data.
  if (!url.href.startsWith(self.registration.scope) ||
      url.search || event.request.headers.has('Authorization')) return;
  event.respondWith(
    fetch(event.request, { cache: 'no-cache' })
      .then((response) => {
        if (response.ok) {
          const copy = response.clone();
          event.waitUntil(
            caches.open(CACHE_NAME)
              .then((cache) => cache.put(event.request, copy))
              .catch(() => {}),
          );
        }
        return response;
      })
      .catch(async () => (await caches.match(event.request)) || Response.error()),
  );
});
