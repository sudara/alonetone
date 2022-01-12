const { webpackConfig, merge } = require('@rails/webpacker')

const customConfig = {
  output: {
    library: 'Alonetone',
    libraryTarget: 'var',
  },
}
module.exports = merge(webpackConfig, customConfig)
