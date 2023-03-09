import { Controller } from "@hotwired/stimulus"

const SELECTED_PICKABLE_DATA_ATTRIBUTE = "data-picker-selected-pickable"
const FAKE_INPUT_LABEL_TEMPLATE_SELECTOR = "[data-picker-fake-input-label-template]"

export default class extends Controller {
  static targets = [
    "modalWrapper",
    "clearButton",
    "fakeInput",
    "hiddenInput",
    "searchInput",
    "searchResults",
    "pickable",
  ]

  static values = {
    url: String,
    allowClear: Boolean,
  }

  connect() {
    this._handleClearButtonVisibility()
  }

  open(event) {
    event.preventDefault()
    event.stopPropagation()

    this.modalWrapperTarget.classList.remove('hidden')

    this.searchInputTarget.focus()
    this._onSearch()
  }

  close(event) {
    if (event) {
      event.preventDefault()
    }
    this.modalWrapperTarget.classList.add('hidden')
  }

  backdropClickClose(event) {
    if (event.target !== this.modalWrapperTarget) {
      return
    }
    this.close()
  }

  clear(event) {
    event.preventDefault()
    event.stopPropagation()

    this.hiddenInputTarget.value = ''
    this._handleClearButtonVisibility()
    this.fakeInputTarget.innerHTML = '(none)'
  }

  // Private functions.

  _select(selected) {
    const currentlySelected = this._currentlySelected()
    if (currentlySelected) {
      currentlySelected.removeAttribute(SELECTED_PICKABLE_DATA_ATTRIBUTE)
    }

    selected.setAttribute(SELECTED_PICKABLE_DATA_ATTRIBUTE, "true")
  }

  _currentlySelected() {
    return this.searchResultsTarget.querySelector(`[${SELECTED_PICKABLE_DATA_ATTRIBUTE}]`)
  }

  _nextPickable() {
    return this._sibling(1)
  }

  _previousPickable() {
    return this._sibling(-1)
  }

  _sibling(offset) {
    const pickables = this.pickableTargets
    const selected = this._currentlySelected()
    const index = pickables.indexOf(selected)
    return pickables[index + offset]
  }

  _pick(selected) {
    const value = selected.getAttribute("data-picker-value")
    this.hiddenInputTarget.value = value

    const fakeInputLabel = selected.querySelector(FAKE_INPUT_LABEL_TEMPLATE_SELECTOR)
    this.fakeInputTarget.innerHTML = ''
    this.fakeInputTarget.insertAdjacentHTML("beforeend", fakeInputLabel.innerHTML)

    this._handleClearButtonVisibility()
    this.close()
  }

  _pickCurrentTarget(event) {
    this._pick(event.currentTarget)
  }

  _onKeydown = (event) => {
    switch (event.key) {
      case 'Escape': {
        this.close()

        event.stopPropagation()
        event.preventDefault()
        break
      }
      case 'ArrowDown': {
        const selected = this._nextPickable()

        if (selected) {
          this._select(selected)
        }
        event.preventDefault()
        break
      }
      case 'ArrowUp': {
        const selected = this._previousPickable()

        if (selected) {
          this._select(selected)
        }
        event.preventDefault()
        break
      }
      case 'Enter': {
        const selected = this._currentlySelected()

        if (selected) {
          this._pick(selected)
          event.preventDefault()
        }
        break
      }
      default: {
        break
      }
    }
  }

  _onSearch = () => {
    this._setSearchResults(this.searchInputTarget.value)
  }

  _setSearchResults = async (query) => {
    const url = `${this.urlValue}&q=${encodeURIComponent(query)}`
    const response = await fetch(url)
    const html = await response.text()

    this.searchResultsTarget.innerHTML = html
  }

  _handleClearButtonVisibility() {
    if (this.allowClearValue && this.hiddenInputTarget.value) {
      this.clearButtonTarget.classList.remove("hidden")
    } else {
      this.clearButtonTarget.classList.add("hidden")
    }
  }
}
