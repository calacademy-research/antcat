// Copied from "./node_modules/@rails/webpacker/package/babel/preset.js".

const { moduleExists } = require('@rails/webpacker')

module.exports = function config(api) {
  const validEnv = ['development', 'test', 'production', 'staging']
  const currentEnv = api.env()
  const isDevelopmentEnv = api.env('development')
  const isProductionEnv = api.env('production')
  const isStagingEnv = api.env('staging')
  const isTestEnv = api.env('test')

  if (!validEnv.includes(currentEnv)) {
    throw new Error(
      `Please specify a valid NODE_ENV or BABEL_ENV environment variable. Valid values are "development", "test", "production", and "staging". Instead, received: "${JSON.stringify(
        currentEnv
      )}".`
    )
  }

  return {
    presets: [
      isTestEnv && ['@babel/preset-env', { targets: { node: 'current' } }],
      (isProductionEnv || isStagingEnv || isDevelopmentEnv) && [
        '@babel/preset-env',
        {
          useBuiltIns: 'entry',
          corejs: '3.8',
          modules: 'auto',
          bugfixes: true,
          loose: true,
          exclude: ['transform-typeof-symbol']
        }
      ],
      moduleExists('@babel/preset-typescript') && [
        '@babel/preset-typescript',
        { allExtensions: true, isTSX: true }
      ],
      moduleExists('@babel/preset-react') && [
        '@babel/preset-react',
        {
          development: isDevelopmentEnv || isTestEnv,
          useBuiltIns: true
        }
      ]
    ].filter(Boolean),
    plugins: [
      ['@babel/plugin-proposal-class-properties', { loose: true }],
      ['@babel/plugin-transform-runtime', { helpers: false }],
      (isProductionEnv || isStagingEnv) &&
        moduleExists('babel-plugin-transform-react-remove-prop-types') && [
          'babel-plugin-transform-react-remove-prop-types',
          { removeImport: true }
        ]
    ].filter(Boolean)
  }
}
