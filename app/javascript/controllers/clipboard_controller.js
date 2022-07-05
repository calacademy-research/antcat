import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  /* eslint-disable */
  static targets = ["source"]
  static values = { stringToCopy: String }
  /* eslint-enable */

  copy(event) {
    event.preventDefault()
    event.stopPropagation()

    navigator.clipboard.writeText(this.stringToCopyValue)
    AntCat.notifySuccess(`Copied "${this.stringToCopyValue}" to clipboard`) // eslint-disable-line no-undef
  }
}
