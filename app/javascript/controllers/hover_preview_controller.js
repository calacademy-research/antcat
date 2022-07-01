import { Controller } from "@hotwired/stimulus"
import { useDebounce, useHover } from 'stimulus-use'

export default class extends Controller {
  static values = { url: String }
  static debounces = [
    { name: 'show', wait: 250 },
    { name: 'hide', wait: 100 }
  ]

  connect() {
    this.isVisible = false
    useDebounce(this)
    useHover(this, { element: this.element })

    this.previewWrapper = document.createElement('span')
    this.previewWrapper.classList.add('stimulus-hover-preview')
    this.previewWrapper.classList.add('hidden')
    this.element.appendChild(this.previewWrapper)
    this.previewContent = null
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
        this.previewWrapper.classList.remove("hidden")
      }
    } else {
      fetch(this.urlValue).
        then((r) => r.text()).
        then((html) => {
          this.previewContent = document.createElement('span')
          this.previewContent.innerHTML = JSON.parse(html).preview

          // NOTE: Hacky way to prevent previews from having previewable links themselves;
          // this will not work if the same element has more than one controller.
          this.previewContent.
            querySelectorAll("[data-controller^='hover-preview']").
            forEach((element) => element.removeAttribute("data-controller"))

          this.previewWrapper.appendChild(this.previewContent)

          if (this.isVisible) {
            this.previewWrapper.classList.remove("hidden")
          }
        })
    }
  }

  hide() {
    this.previewWrapper.classList.add("hidden")
  }
}
