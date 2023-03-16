import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  success(event) {
    AntCat.notifySuccess(event.params.message)
  }
}
