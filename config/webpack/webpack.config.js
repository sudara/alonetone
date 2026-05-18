const { generateWebpackConfig, merge } = require('shakapacker')

const customConfig = {
  output: {
    library: 'Alonetone',
    libraryTarget: 'var',
  },
  performance: {
    maxAssetSize: 400_000,
    maxEntrypointSize: 500_000,
  },
}
module.exports = merge(generateWebpackConfig(), customConfig)
