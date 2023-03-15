import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  csrfToken() {
    const element = document.head.querySelector('meta[name="csrf-token"]')

    if (element) {
      return element.getAttribute("content")
    } else {
      // This should only happen in the test env. Use the RSpec meta tag `:protect_from_forgery` to enable CSRF in specs.
      throw new Error("cannot read csrf-token")
    }
  }
}
