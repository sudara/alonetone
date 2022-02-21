const { webpackConfig, merge } = require('shakapacker')

const customConfig = {
  output: {
    library: 'Alonetone',
    libraryTarget: 'var',
  },
}
module.exports = merge(webpackConfig, customConfig)
