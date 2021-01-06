import Vue from 'vue/dist/vue.esm'

// TODO: Temporary random component with styles to make the compilation step not blow up.
import TestDirective from './components/TestDirective'

import CreateHoverPreview from './directives/CreateHoverPreview'
import CachedFetcher from './services/CachedFetcher'
import * as ApiUrls from './config/ApiUrls'

window.AntCatVue ||= {}

Vue.config.productionTip = false
Vue.config.devtools = false

// HACK: To make server-rendered HTML in markdown previews works. Very hacky and
// it will remain so for a some (long) time as long as we're mixing jQuery and Vue.
window.AntCatVue.askForRecompile = function(element) {
  const html = $(element).prop("outerHTML")
  const res = Vue.compile(html)

  new Vue({
    render: res.render,
    staticRenderFns: res.staticRenderFns,
  }).$mount($(element)[0])
}

const taxonFetcher = new CachedFetcher(ApiUrls.previewTaxonUrl)
const protonymFetcher = new CachedFetcher(ApiUrls.previewProtonymUrl)
const refereneFetcher = new CachedFetcher(ApiUrls.previewReferenceUrl)

Vue.directive('hover-taxon', CreateHoverPreview(taxonFetcher))
Vue.directive('hover-protonym', CreateHoverPreview(protonymFetcher))
Vue.directive('hover-reference', CreateHoverPreview(refereneFetcher))

Vue.directive('test-directive', TestDirective)

document.addEventListener('DOMContentLoaded', () => {
  new Vue({
    el: '#vue-app',
    components: {
      TestDirective,
    },
  })
})
