import Bugsnag from '@bugsnag/js'

const apiKeyMeta = document.querySelector('meta[name="bugsnag-api-key"]')
const apiKey = apiKeyMeta?.content || 'A'.repeat(32)

Bugsnag.start({
  apiKey,
  appType: 'js',
  enabledReleaseStages: ['production'],
  user: {
    name: window.username,
  },
})
