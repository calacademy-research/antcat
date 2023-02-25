import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { href: String }

  connect() {
    if (this.hasHrefValue) {
      this.element.querySelectorAll(`a[href*="${this.hrefValue}"]`).
        forEach((element) => element.classList.add('bg-yellow'))
    }
  }
}
