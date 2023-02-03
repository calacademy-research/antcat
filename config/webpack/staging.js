process.env.NODE_ENV = process.env.NODE_ENV || 'staging'

const webpackConfig = require('./base')

module.exports = webpackConfig
