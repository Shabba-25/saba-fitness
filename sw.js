const CACHE = 'saba-fit-v4';

// Static assets that rarely change — cache first
const STATIC = ['/manifest.json'];

// HTML — always network first so updates show immediately
const HTML = ['/', '/index.html'];

self.addEventListener('install', e => {
  e.waitUntil(
    caches.open(CACHE)
      .then(c => c.addAll(STATIC))
      .then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k)))
    ).then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', e => {
  const url = new URL(e.request.url);

  // Skip non-GET and external requests (Supabase API calls etc)
  if (e.request.method !== 'GET' || !url.origin.includes(self.location.origin)) return;

  const isHTML = HTML.some(p => url.pathname === p || url.pathname.endsWith('/'));

  if (isHTML) {
    // Network first — always get fresh HTML, fall back to cache if offline
    e.respondWith(
      fetch(e.request)
        .then(res => {
          if (res && res.status === 200) {
            const copy = res.clone();
            caches.open(CACHE).then(c => c.put(e.request, copy));
          }
          return res;
        })
        .catch(() => caches.match(e.request).then(c => c || caches.match('/index.html')))
    );
  } else {
    // Cache first for everything else (fonts, manifest etc)
    e.respondWith(
      caches.match(e.request).then(cached => {
        if (cached) return cached;
        return fetch(e.request).then(res => {
          if (res && res.status === 200) {
            const copy = res.clone();
            caches.open(CACHE).then(c => c.put(e.request, copy));
          }
          return res;
        }).catch(() => caches.match('/index.html'));
      })
    );
  }
});
