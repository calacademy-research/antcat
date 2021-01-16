import Vue from 'vue'

import store from '@/store'

import ThePanel from "@components/Panel/ThePanel"
import RecordPicker from "@components/Picker/RecordPicker"

import * as ApiUrls from '@config/ApiUrls'
import CachedFetcher from '@services/CachedFetcher'
import CreateHoverPreview from '@directives/CreateHoverPreview'
import TestDirective from '@components/TestDirective'

window.AntCatVue ||= {}

Vue.config.productionTip = false
Vue.config.devtools = false

// HACK: To make server-rendered HTML in markdown previews works. Very hacky and
// it will remain so for a some (long) time as long as we're mixing jQuery and Vue.
window.AntCatVue.askForRecompile = function(element) {
  const html = $(element).prop("outerHTML") // eslint-disable-line no-undef
  const res = Vue.compile(html)

  new Vue({
    components: { RecordPicker }, // Include `RecordPicker` since we're returning pickers in `HistoryItemsController`.
    render: res.render,
    staticRenderFns: res.staticRenderFns,
  }).$mount($(element)[0]) // eslint-disable-line no-undef
}

const taxonFetcher = new CachedFetcher(ApiUrls.previewTaxonUrl)
const protonymFetcher = new CachedFetcher(ApiUrls.previewProtonymUrl)
const refereneFetcher = new CachedFetcher(ApiUrls.previewReferenceUrl)

Vue.directive('hover-taxon', CreateHoverPreview(taxonFetcher))
Vue.directive('hover-protonym', CreateHoverPreview(protonymFetcher))
Vue.directive('hover-reference', CreateHoverPreview(refereneFetcher))

Vue.directive('test-directive', TestDirective)

document.addEventListener('DOMContentLoaded', () => {
  new Vue({ // eslint-disable-line no-new
    el: '#vue-app',
    store,
    components: {
      TestDirective,

      ThePanel,
      RecordPicker,
    },
  })
})
