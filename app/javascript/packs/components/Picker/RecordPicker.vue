<template>
  <div class="record-picker-fake-input">
    <button class="btn-tiny btn-nodanger" @click.prevent="askForRecord">
      Pick
    </button>
    <button v-show="item.id" class="btn-tiny btn-nodanger" @click.prevent="clear">
      Clear
    </button>

    <span v-show="!item.id">(none)</span>

    <span v-if="isTaxaPickableType">
      <HoverTaxon v-if="item" :item="item" />
    </span>

    <span v-if="isProtonymsPickableType">
      <HoverProtonym v-if="item" :item="item" />
    </span>

    <span v-if="isReferencesPickableType">
      <HoverReference v-if="item" :item="item" />
    </span>
  </div>
</template>

<script>
import { PICKABLE_TYPES } from '@config/constants'

import EventBus from '@services/EventBus'
import keysToCamel from '@utils/keysToCamel'

import HoverTaxon from '@components/HoverTaxon'
import HoverProtonym from '@components/HoverProtonym'
import HoverReference from '@components/HoverReference'

export default {
  name: 'RecordPicker',
  components: {
    HoverTaxon, HoverProtonym, HoverReference,
  },
  props: {
    pickableType: {
      type: String,
      required: true,
      validator(value) {
        return [PICKABLE_TYPES.TAXA, PICKABLE_TYPES.PROTONYMS, PICKABLE_TYPES.REFERENCES].indexOf(value) !== -1
      },
    },
    pickableRanks: {
      type: Array,
      default() {
        return []
      },
    },
    pickerId: { type: String, required: true },
    initialItem: {
      type: Object,
      default() {
        return {}
      },
    },
  },
  data() {
    return {
      item: keysToCamel(this.initialItem),
    }
  },
  computed: {
    isTaxaPickableType() {
      return this.pickableType === PICKABLE_TYPES.TAXA
    },
    isProtonymsPickableType() {
      return this.pickableType === PICKABLE_TYPES.PROTONYMS
    },
    isReferencesPickableType() {
      return this.pickableType === PICKABLE_TYPES.REFERENCES
    },
  },
  created() {
    EventBus.$on(`reply-with-record-for-${this._uid}`, (pickableType, recordId, item) => {
      if (pickableType !== this.pickableType) {
        alert("incorrect pickable type????")
      } else {
        this.item = item
        this.setExternalInput(recordId)
        this.hideExternalInput()
      }
    })
  },
  mounted() {
    this.hideExternalInput()
  },
  methods: {
    clear() {
      this.item = {}
      this.setExternalInput("")
      this.$store.dispatch('notifySuccess', "Cleared pickable")
    },
    externalInput() {
      return document.querySelector(`input[data-picker-id='${this.pickerId}']`)
    },
    hideExternalInput() {
      this.externalInput().style.display = 'none'
    },
    setExternalInput(value) {
      this.externalInput().value = value
    },
    askForRecord() {
      this.$store.dispatch('requestRecord', {
        recordAskerUid: this._uid,
        pickableType: this.pickableType,
        pickableRanks: this.pickableRanks,
      })
    },
  },
}
</script>

<style>
.record-picker-fake-input {
  border-radius: 4px;
  border: 1px solid #ccc;
  height: 2.2rem;
  padding-top: 0.2rem;
  padding-bottom: 0.2rem;
  padding-left: 0.4rem;
  padding-right: 0.4rem;
  min-width: 15rem;
  display: inline-block;
}
</style>
