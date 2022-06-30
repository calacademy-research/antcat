const HoverRecord = {
  props: {
    item: {
      type: Object,
      required: false,
      default() {
        return {}
      },
    },
    disableLink: { type: Boolean, required: false },
  },
  data() {
    return {
      isHover: false,
      contentFetchedForId: false,
      previewContent: null,
    }
  },
  computed: {
    itemUrl() {
      if (this.disableLink) {
        return
      } else {
        const { url } = this.item
        return url
      }
    },
  },
  methods: {
    onMouseover() {
      this.isHover = true

      const recordId = this.item.id

      if (this.isFetching || this.contentFetchedForId === recordId) {
        return
      }
      this.isFetching = true

      this.fetcher().fetch(recordId).
        then((data) => { this.previewContent = data.preview }).
        then((_data) => { this.isFetching = false; this.contentFetchedForId = recordId })
    },
    onMouseleave() {
      this.isHover = false
    },
  },
}

export default HoverRecord
