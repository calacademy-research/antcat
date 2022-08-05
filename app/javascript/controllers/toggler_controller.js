import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  toggle(event) {
    event.preventDefault()

    const target = event.currentTarget.dataset.togglerTarget
    const onClass = event.currentTarget.dataset.togglerOnClass || "is-hidden"

    document.
      querySelectorAll(`[data-toggler-name="${target}"]`).
      forEach((target) => target.classList.toggle(onClass))
  }
}
