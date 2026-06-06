import Bugsnag from '@bugsnag/js'

const apiKey = document.querySelector('meta[name="bugsnag-api-key"]')?.content

if (apiKey) {
  Bugsnag.start({
    apiKey,
    appType: 'js',
    enabledReleaseStages: ['production'],
    user: { name: window.username },
  })
}
