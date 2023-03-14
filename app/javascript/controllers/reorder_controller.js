import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static targets = [
    "hiddenInput",
    "sortableList",
  ]

  connect () {
    this.sortable = new Sortable(this.sortableListTarget, { dataIdAttr: 'data-sortable-id', onSort: () => this._onSort() })
  }

  _onSort() {
    this.hiddenInputTarget.value = this.sortable.toArray().join(',')
  }
}
