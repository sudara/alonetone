const { environment } = require('@rails/webpacker')
const erb = require('./loaders/erb')

environment.config.merge({
  output: {
    library: 'Alonetone',
    libraryTarget: 'var',
  },
})
environment.loaders.append('erb', erb)
module.exports = environment
// webpack.config.js
