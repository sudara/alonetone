const { environment } = require('@rails/webpacker')
const erb =  require('./loaders/erb')

environment.config.set('output.library', 'alonetone')
environment.loaders.append('erb', erb)
module.exports = environment
// webpack.config.js
