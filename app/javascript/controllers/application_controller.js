import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  csrfToken() {
    const element = document.head.querySelector('meta[name="csrf-token"]')

    if (element) {
      return element.getAttribute("content")
    } else {
      // TODO: Hack because CSRF is disabled in the test env. Figure out how to best handle.
      return "???"
    }
  }
}
