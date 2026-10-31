import { Controller } from "@hotwired/stimulus"
import { useDebounce, useHover } from 'stimulus-use'

export default class extends Controller {
  static targets = ["link"]

  static values = {
    url: String,
  }

  static debounces = [
    { name: 'show', wait: 400 },
    { name: 'hide', wait: 100 },
  ]

  connect() {
    this.isVisible = false
    useDebounce(this)
    useHover(this, { element: this.element })

    this.url = this.linkTarget.href
    // Only web pages are previewed (an older stored URL may have another scheme, e.g. `javascript:`).
    if (!this._isWebUrl(this.url)) return

    this.container = this._createContainer(this.url)
    this.iframe = this._createIframe()

    this.container.appendChild(this.iframe)
    this.element.appendChild(this.container)
  }

  disconnect() {
    if (this.container) {
      this.container.remove()
    }
  }

  mouseEnter() {
    this.isVisible = true
    this.show()
  }

  mouseLeave() {
    this.isVisible = false
    this.hide()
  }

  show() {
    if (!this.iframe) return
    if (!this.iframe.hasAttribute("src")) {
      this.iframe.src = this.url
    }

    if (this.isVisible) {
      this.container.classList.remove("hidden")
    }
  }

  hide() {
    if (this.container) this.container.classList.add("hidden")
  }

  _isWebUrl(url) {
    try {
      const protocol = new URL(url, window.location.href).protocol
      return protocol === "http:" || protocol === "https:"
    } catch {
      return false
    }
  }

  _createContainer(url) {
    const element = document.createElement('div')
    element.classList.add('hidden')
    element.classList.add('external-preview-modal')

    const heading = document.createElement('h6')
    const link = document.createElement('a')
    link.href = url
    link.classList.add('external-link')
    link.textContent = url
    heading.append('Preview of ', link)
    element.appendChild(heading)

    return element
  }

  _createIframe() {
    const element = document.createElement('iframe')
    element.setAttribute("height", "100%")
    element.setAttribute("width", "100%")
    element.setAttribute("frameborder", "0")

    return element
  }
}
