/*

This file should go away. 

However, we want to support older broswer such as FF ESR.

The problem is that stimulus now requires ES6+ features and doesn't
target ES5 anymore. So we need to tell babel to do that for us.

See:
https://github.com/rails/webpacker/pull/3189#issuecomment-994959987


*/
const { moduleExists } = require('shakapacker')

module.exports = function config(api) {
  const validEnv = ['development', 'test', 'production']
  const currentEnv = api.env()
  const isDevelopmentEnv = api.env('development')
  const isProductionEnv = api.env('production')
  const isTestEnv = api.env('test')

  if (!validEnv.includes(currentEnv)) {
    throw new Error(
      `Please specify a valid NODE_ENV or BABEL_ENV environment variable. Valid values are "development", "test", and "production". Instead, received: "${JSON.stringify(
        currentEnv
      )}".`
    )
  }

  return {
    presets: [
      isTestEnv && ['@babel/preset-env', { targets: { node: 'current' } }],
      (isProductionEnv || isDevelopmentEnv) && [
        '@babel/preset-env',
        {
          useBuiltIns: 'entry',
          corejs: '3.8',
          modules: 'auto',
          bugfixes: true,
          loose: false,
          exclude: ['transform-typeof-symbol']
        }
      ],
      moduleExists('@babel/preset-typescript') && [
        '@babel/preset-typescript',
        { allExtensions: true, isTSX: true }
      ]
    ].filter(Boolean),
    plugins: [
      ['@babel/plugin-transform-runtime', { helpers: false }]
    ].filter(Boolean)
  }
}
