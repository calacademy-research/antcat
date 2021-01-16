<template>
  <div @keyup.esc="closePanel">
    <p>
      <span class="pickable">Pickable type: {{ pickableType }}</span>
      <span v-show="pickableRanks.length">Pickable ranks: {{ pickableRanks.join(', ') }} (only works for taxa)</span>
    </p>

    <vue-autosuggest
      ref="autosuggest"
      v-model="query"
      :suggestions="suggestions"
      :input-props="inputProps"
      :section-configs="sectionConfigs"
      :get-suggestion-value="getSuggestionValue"
      @input="fetchResults"
    >
      <template slot-scope="{suggestion}">
        <div>
          <div v-if="suggestion.name === 'taxa'">
            <span class="record-id">{{ suggestion.item.id }}</span>

            <span :class="isTaxaPickableType && 'pickable'">
              <HoverTaxon disable-link :item="suggestion.item" />
            </span>

            <span :class="isProtonymsPickableType && 'pickable'">
              Protonym:
              <HoverProtonym disable-link :item="suggestion.item.protonym" />
            </span>
          </div>

          <div v-else-if="suggestion.name === 'protonyms'">
            <span class="record-id">{{ suggestion.item.id }}</span>

            <span :class="isProtonymsPickableType && 'pickable'">
              <HoverProtonym disable-link :item="suggestion.item" />
            </span>

            <span :class="isTaxaPickableType && 'pickable'">
              Terminal taxon:
              <span v-show="!suggestion.item.terminalTaxon" class="bold-warning">No terminal taxon</span>
              <HoverTaxon disable-link :item="suggestion.item.terminalTaxon" />
            </span>
          </div>

          <div v-else-if="suggestion.name === 'references'">
            <span class="record-id">{{ suggestion.item.id }}</span>

            <HoverReference disable-link :item="suggestion.item" />
            <span class="reference-suggestion-full-pagination">[pagination: {{ suggestion.item.fullPagination }}]</span>

            <div class="reference-suggestion-title">
              {{ suggestion.item.title }}
            </div>
          </div>

          <div v-else>
            ??????????????
          </div>
        </div>
      </template>
    </vue-autosuggest>
  </div>
</template>

<script>
import { mapState } from 'vuex'
import { VueAutosuggest } from "vue-autosuggest"
import axios from "axios"

import { PICKABLE_TYPES } from '@config/constants'
import camelCaseResponse from '@utils/camelCaseResponse'

import HoverTaxon from '@components/HoverTaxon'
import HoverProtonym from '@components/HoverProtonym'
import HoverReference from '@components/HoverReference'

export default {
  name: "PickerSearchForm",
  components: {
    VueAutosuggest,
    HoverTaxon,
    HoverProtonym,
    HoverReference,
  },
  data() {
    return {
      query: "",
      results: [],
      selected: null,
      // TODO: Move to config.
      taxaUrl: "/catalog/autocomplete?include_protonym=yes",
      protonymsUrl: "/protonyms/autocomplete?include_terminal_taxon=yes",
      referencesUrl: "/references/autocomplete",
      inputProps: {
        id: "autosuggest__input",
        placeholder: "Search",
      },
      suggestions: [],
      sectionConfigs: {
        default: {
          limit: 6,
          onSelected: (_item, _originalInput) => {
            if (this.suggestions.length === 1) {
              const onlySuggestion = this.suggestions[0]

              const selected = {
                name: onlySuggestion.name,
                item: onlySuggestion.data[0],
              }
              this.replyWithPickableFromSelected(selected)
            }
          },
        },
        taxa: {
          limit: 7,
          label: "Taxa",
          onSelected: this.replyWithPickableFromSelected,
        },
        protonyms: {
          limit: 7,
          label: "Protonyms",
          onSelected: this.replyWithPickableFromSelected,
        },
        references: {
          limit: 9,
          onSelected: this.replyWithPickableFromSelected,
        },
      },
    }
  },
  computed: {
    ...mapState({
      recordAskerUid: 'pickerRequesterUid',
      pickableType: 'pickerTypes',
      pickableRanks: 'pickerRanks',
    }),
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
  mounted() {
    this.focusInput()
  },
  methods: {
    fetchResults() {
      const { query } = this

      if (this.isTaxaPickable() || this.isProtonymsPickable()) {
        const taxaPromise = axios.
          get(this.taxaUrl, { params: { qq: query, rank: this.pickableRanks }, transformResponse: camelCaseResponse })
        const protonymsPromise = axios.
          get(this.protonymsUrl, { params: { qq: query }, transformResponse: camelCaseResponse })

        Promise.all([taxaPromise, protonymsPromise]).then((values) => {
          this.suggestions = []
          this.selected = null

          const taxa = values[0].data
          const protonyms = values[1].data

          taxa.length && this.suggestions.push({ name: PICKABLE_TYPES.TAXA, data: taxa })
          protonyms.length && this.suggestions.push({ name: PICKABLE_TYPES.PROTONYMS, data: protonyms })
        })
      } else if (this.isReferencesPickable()) {
        const referencesPromise = axios.
          get(this.referencesUrl, { params: { reference_q: query }, transformResponse: camelCaseResponse })

        Promise.all([referencesPromise]).then((values) => {
          this.suggestions = []
          this.selected = null

          const references = values[0].data

          references.length && this.suggestions.push({ name: PICKABLE_TYPES.REFERENCES, data: references })
        })
      } else {
        alert(`Unknown pickable type: ${this.pickableType}`)
      }
    },
    replyWithPickableFromSelected(selected) {
      const { item } = selected

      if (selected.name === PICKABLE_TYPES.TAXA) {
        this.replyWithTaxon(item)
      } else if (selected.name === PICKABLE_TYPES.PROTONYMS) {
        this.replyWithProtonym(item)
      } else if (selected.name === PICKABLE_TYPES.REFERENCES) {
        this.replyWithReference(item)
      }
    },
    replyWithTaxon(item) {
      if (this.isProtonymsPickableType) {
        this.replyWithRecord(PICKABLE_TYPES.PROTONYMS, item.protonym, "Picked protonym of taxon")
      } else if (this.isTaxaPickableType) {
        this.replyWithRecord(PICKABLE_TYPES.TAXA, item, "Picked taxon")
      } else {
        alert(`Only ${this.pickableType} may be picked`)
      }
    },
    replyWithProtonym(item) {
      if (this.isProtonymsPickableType) {
        this.replyWithRecord(PICKABLE_TYPES.PROTONYMS, item, "Picked protonym")
      } else if (this.isTaxaPickableType) {
        const { terminalTaxon } = item

        if (!terminalTaxon) {
          alert('Cannot pick terminal taxon of protonym')
        } else {
          this.replyWithRecord(PICKABLE_TYPES.TAXA, terminalTaxon, "Picked terminal taxon of protonym")
        }
      } else {
        alert(`Only ${this.pickableType} may be picked`)
      }
    },
    replyWithReference(item) {
      if (this.isReferencesPickableType) {
        this.replyWithRecord(PICKABLE_TYPES.REFERENCES, item, "Picked reference")
      } else {
        alert(`Only ${this.pickableType} may be picked`)
      }
    },
    getSuggestionValue(_suggestion) {
      return this.query // HACK: To maintain search query.
    },
    replyWithRecord(pickableType, pickedItem, notificationMessage) {
      this.$store.dispatch('notifySuccess', notificationMessage)
      this.$store.dispatch('replyWithRecord', {
        recordAskerUid: this.recordAskerUid,
        pickableType,
        pickedItemId: pickedItem.id,
        pickedItem,
      })
      this.reset()
    },
    closePanel() {
      this.$store.dispatch('closePanel')
      this.reset()
    },
    focusInput() {
      // TODO: Fix double nextTick.
      this.$nextTick(() => {
        this.$nextTick(() => {
          this.$refs.autosuggest.$el.querySelector("input").focus()
          this.$refs.autosuggest.$el.querySelector("input").select()
        })
      })
    },
    isTaxaPickable() {
      return this.pickableType === PICKABLE_TYPES.TAXA
    },
    isProtonymsPickable() {
      return this.pickableType === PICKABLE_TYPES.PROTONYMS
    },
    isReferencesPickable() {
      return this.pickableType === PICKABLE_TYPES.REFERENCES
    },
    reset() {
      // TODO: Hmm.
      this.query = ""
      this.results = []
      this.selected = null
      this.$store.dispatch('resetRequestRecord')
    },
  },
}
</script>

<style>
#autosuggest__input {
  outline: none;
  position: relative;
  display: block;
  border: 1px solid #616161;
  padding: 10px;
  width: 100%;
  box-sizing: border-box;
  -webkit-box-sizing: border-box;
  -moz-box-sizing: border-box;
}

#autosuggest__input.autosuggest__input-open {
  border-bottom-left-radius: 0;
  border-bottom-right-radius: 0;
}

.autosuggest__results-container {
  position: relative;
  width: 100%;
}

.autosuggest__results {
  font-weight: 300;
  margin: 0;
  position: absolute;
  z-index: 1000;
  width: 100%;
  border: 1px solid #e0e0e0;
  border-bottom-left-radius: 4px;
  border-bottom-right-radius: 4px;
  background: white;
  padding: 0px;
  max-height: 90vh;
  overflow-y: scroll;
}

.autosuggest__results ul {
  list-style: none;
  padding-left: 0;
  margin: 0;
}

.autosuggest__results .autosuggest__results-item {
  cursor: cell;
  padding: 7px;
}

#autosuggest ul:nth-child(1) > .autosuggest__results_title {
  border-top: none;
}

.autosuggest__results .autosuggest__results-before {
  color: gray;
  font-size: 11px;
  margin-left: 0;
  padding: 15px 13px 5px;
  border-top: 1px solid lightgray;
}

.autosuggest__results .autosuggest__results-item:active,
.autosuggest__results .autosuggest__results-item:hover,
.autosuggest__results .autosuggest__results-item:focus,
.autosuggest__results .autosuggest__results-item.autosuggest__results-item--highlighted {
  background-color: #ddd;
}

.pickable {
  border: 1px solid #777;
  border-radius: 3px;
  padding: 3px;
  background-color: #fff;
}

.record-id {
  color: darkgray;
  font-size: 90%;
  margin-right: 1rem;
}

.reference-suggestion-full-pagination, .reference-suggestion-title {
  font-size: 90%;
}
</style>
