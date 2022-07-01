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

// HACK: To render HTML returned by Ajax. We need this to make elements
// with record pickers work after being inserted by JS.
// Test by quick-editing + saving and then quick-editing the same history item again (for example
// a 'junior_synonym_of' item like one on http://localhost:3000/protonyms/156600).
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
