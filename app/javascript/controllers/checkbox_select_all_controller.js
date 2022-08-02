import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["parentCheckbox", "checkbox"]

  toggle() {
    if (this.parentCheckboxTarget.checked) {
      this.checkboxTargets.forEach((checkbox) => { checkbox.checked = true })
    } else {
      this.checkboxTargets.forEach((checkbox) => { checkbox.checked = false })
    }
  }
}
