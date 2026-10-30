import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { stringToCopy: String }

  copy(event) {
    event.preventDefault()
    event.stopPropagation()

    const copied = this.stringToCopyValue
    // The notification is HTML: the copied text is shown as text. Success is said only once the copy worked.
    const shown = document.createElement("span")
    shown.textContent = copied
    navigator.clipboard.writeText(copied).
      then(() => AntCat.notifySuccess(`Copied "${shown.innerHTML}" to clipboard`)).
      catch(() => AntCat.notifyError("Could not copy to the clipboard"))
  }
}
