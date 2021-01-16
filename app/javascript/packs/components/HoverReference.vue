<template>
  <span>
    <a :href="itemUrl" @mouseover="onMouseover" @mouseleave="onMouseleave">
      <span v-html="item.keyWithSuffixedYear" />

      <div v-show="isHover" class="vue-hover-preview-component" @mouseleave="onMouseleave">
        <span ref="preview_content" @mouseleave="onMouseleave" v-html="previewContent" />
      </div>
    </a>
  </span>
</template>

<script>
import HoverRecord from '@mixins/HoverRecord'
import { previewReferenceUrl } from '@config/ApiUrls'
import CachedFetcher from '@services/CachedFetcher'

const fetcher = new CachedFetcher(previewReferenceUrl)

export default {
  name: 'HoverReference',
  mixins: [HoverRecord],
  methods: {
    fetcher() {
      return fetcher
    },
  },
}
</script>
