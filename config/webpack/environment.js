const { environment } = require('@rails/webpacker')
const resolveAliases = require('./resolve_aliases')

const { VueLoaderPlugin } = require('vue-loader')
const vue = require('./loaders/vue')

environment.plugins.prepend('VueLoaderPlugin', new VueLoaderPlugin())
environment.loaders.prepend('vue', vue)

environment.config.merge(resolveAliases)

module.exports = environment
