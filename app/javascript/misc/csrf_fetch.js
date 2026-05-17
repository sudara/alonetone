export default function csrfFetch(url, options = {}) {
  const token = document.querySelector('meta[name="csrf-token"]')?.content
  return fetch(url, {
    credentials: 'same-origin',
    ...options,
    headers: {
      'X-CSRF-Token': token,
      'X-Requested-With': 'XMLHttpRequest',
      ...options.headers,
    },
  })
}
