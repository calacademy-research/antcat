import Vue from 'vue/dist/vue.esm'
import TestDirective from './components/TestDirective'

Vue.directive('test-directive', TestDirective)

document.addEventListener('DOMContentLoaded', () => {
  new Vue({
    el: '#vue-app',
    components: {
      TestDirective,
    },
  })
})
