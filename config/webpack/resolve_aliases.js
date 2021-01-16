const path = require('path')

module.exports = {
  resolve: {
    alias: {
      'vue$': 'vue/dist/vue.esm',
      '@': path.resolve(__dirname, '..', '..', 'app/javascript/packs'),
      '@components': path.resolve(__dirname, '..', '..', 'app/javascript/packs/components'),
      '@config': path.resolve(__dirname, '..', '..', 'app/javascript/packs/config'),
      '@directives': path.resolve(__dirname, '..', '..', 'app/javascript/packs/directives'),
      '@mixins': path.resolve(__dirname, '..', '..', 'app/javascript/packs/mixins'),
      '@services': path.resolve(__dirname, '..', '..', 'app/javascript/packs/services'),
      '@utils': path.resolve(__dirname, '..', '..', 'app/javascript/packs/utils')
    }
  }
}
