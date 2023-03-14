import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "copyFrom",
    "copyTo",
  ]

  copy(event) {
    event.preventDefault()

    this.copyToTarget.value = this.copyFromTarget.value

    // To trigger the name conflict check.
    this.copyToTarget.dispatchEvent(new Event('keyup'))
  }
}
