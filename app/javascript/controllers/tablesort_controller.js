import { Controller } from "@hotwired/stimulus"
import Tablesort from "tablesort"

export default class extends Controller {
  connect() {
    new Tablesort(this.element) // eslint-disable-line no-new
  }
}
