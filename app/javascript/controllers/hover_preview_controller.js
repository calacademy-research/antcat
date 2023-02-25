import { Controller } from "@hotwired/stimulus"
import { useDebounce, useHover } from 'stimulus-use'

export default class extends Controller {
  static values = { url: String }

  static debounces = [
    { name: 'show', wait: 250 },
    { name: 'hide', wait: 100 },
  ]

  connect() {
    this.isVisible = false
    useDebounce(this)
    useHover(this, { element: this.element })

    this.container = document.createElement('span')
    this.container.classList.add('stimulus-hover-preview')
    this.container.classList.add('hidden')
    this.element.appendChild(this.container)
    this.previewContent = null
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
    if (this.previewContent) {
      if (this.isVisible) {
        this.container.classList.remove("hidden")
      }
    } else {
      fetch(this.urlValue).
        then((response) => response.text()).
        then((html) => {
          this.previewContent = document.createElement('span')
          this.previewContent.innerHTML = JSON.parse(html).preview

          // NOTE: Hacky way to prevent previews from having previewable links themselves;
          // this will not work if the same element has more than one controller.
          this.previewContent.
            querySelectorAll("[data-controller^='hover-preview']").
            forEach((element) => element.removeAttribute("data-controller"))

          this.container.appendChild(this.previewContent)

          if (this.isVisible) {
            this.container.classList.remove("hidden")
          }
        })
    }
  }

  hide() {
    this.container.classList.add("hidden")
  }
}
