const { generateWebpackConfig, merge } = require('shakapacker')

const customConfig = {
  output: {
    library: 'Alonetone',
    libraryTarget: 'var',
  },
}
module.exports = merge(generateWebpackConfig(), customConfig)
