import { Controller } from "@hotwired/stimulus"

const IS_ENABLED_LOCAL_STORAGE_KEY = 'discoModeEnabled'

const COLOR_CODED_CATALOG_LINKS_CLASS = "color-coded-catalog-links"
const SHOW_FIREWORKS_CLASS = "show-fireworks"

export default class extends Controller {
  static targets = [
    "toggleButton",
  ]

  connect() {
    this.container = document.body

    if (this._isEnabled()) {
      this._activate()
    } else {
      this._deactivate()
    }

    this.toggleButtonTarget.classList.remove('hidden')
  }

  toggle(event) {
    event.preventDefault()

    if (this._isActive()) {
      this._deactivate()
    } else {
      this._activate()
      this.container.classList.add(SHOW_FIREWORKS_CLASS)
    }
  }

  _isEnabled() {
    return localStorage.getItem(IS_ENABLED_LOCAL_STORAGE_KEY)
  }

  _isActive() {
    return this.container.classList.contains(COLOR_CODED_CATALOG_LINKS_CLASS)
  }

  _activate() {
    this.container.classList.add(COLOR_CODED_CATALOG_LINKS_CLASS)
    this.toggleButtonTarget.textContent = "Leave the disco :("

    localStorage.setItem(IS_ENABLED_LOCAL_STORAGE_KEY, true)
  }

  _deactivate() {
    this.container.classList.remove(COLOR_CODED_CATALOG_LINKS_CLASS)
    this.toggleButtonTarget.textContent = "Go to the disco!"
    this.container.classList.remove(SHOW_FIREWORKS_CLASS)

    localStorage.removeItem(IS_ENABLED_LOCAL_STORAGE_KEY)
  }
}
