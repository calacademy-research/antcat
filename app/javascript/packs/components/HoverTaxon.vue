<template>
  <span>
    <a :href="itemUrl" @mouseover="onMouseover" @mouseleave="onMouseleave">
      <span :class="item.cssClasses" v-html="item.nameWithFossil" />

      <div v-show="isHover" class="vue-hover-preview-component" @mouseleave="onMouseleave">
        <span ref="preview_content" @mouseleave="onMouseleave" v-html="previewContent" />
      </div>
    </a>

    <span class="discreet-author-citation" v-html="item.authorCitation" />
  </span>
</template>

<script>
import HoverRecord from '@mixins/HoverRecord'
import { previewTaxonUrl } from '@config/ApiUrls'
import CachedFetcher from '@services/CachedFetcher'

const fetcher = new CachedFetcher(previewTaxonUrl)

export default {
  name: 'HoverTaxon',
  mixins: [HoverRecord],
  methods: {
    fetcher() {
      return fetcher
    },
  },
}
</script>
