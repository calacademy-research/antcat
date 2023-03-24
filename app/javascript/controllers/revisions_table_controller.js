import { Controller } from "@hotwired/stimulus"

// This is for hiding unavailable radio options in the revision history table.
// See https://en.wikipedia.org/w/index.php?title=Example&action=history for how it is supposed to work.

export default class extends Controller {
  static targets = ["leftRadio", "rightRadio"]

  connect() {
    if (!this.leftRadioTargets.some((radio) => radio.checked)) {
      const checkLeftRadioIndex = this.rightRadioIndex + 1
      this.leftRadioTargets.find((radio) => parseInt(radio.dataset.radioIndex) === checkLeftRadioIndex).checked = true
    }

    this.updateAvailable()
  }

  updateAvailable() {
    const rightIndex = this.rightRadioIndex
    const leftIndex = this.leftRadioIndex

    this._showAllRadios()

    this.leftRadioTargets.
      filter((radio) => radio.dataset.radioIndex <= rightIndex).
      forEach((radio) => { radio.classList.add("hidden") })

    this.rightRadioTargets.
      filter((radio) => radio.dataset.radioIndex >= leftIndex).
      forEach((radio) => { radio.classList.add("hidden") })
  }

  _showAllRadios() {
    this.leftRadioTargets.forEach((radio) => { radio.classList.remove("hidden") })
    this.rightRadioTargets.forEach((radio) => { radio.classList.remove("hidden") })
  }

  get leftRadioIndex() {
    return parseInt(this.leftRadioTargets.find((radio) => radio.checked).dataset.radioIndex)
  }

  get rightRadioIndex() {
    return parseInt(this.rightRadioTargets.find((radio) => radio.checked).dataset.radioIndex)
  }
}
