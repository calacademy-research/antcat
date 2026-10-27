import { Controller } from "@hotwired/stimulus"
import { useDebounce } from 'stimulus-use'

// TODO: Improve.

export default class extends Controller {
  static targets = [
    "input",
    "results",
  ]

  static debounces = [
    { name: 'check', wait: 300 },
  ]

  connect() {
    useDebounce(this)
    this.requestSequence = 0
  }

  check(event) {
    // Responses can arrive out of order; only the answer to the latest request is shown.
    const sequence = ++this.requestSequence
    const queryParams = {
      qq: this.inputTarget.value,
      name_scope: event.params?.nameScope ? event.params.nameScope : "",
      except_name_id: event.params?.exceptNameId ? event.params.exceptNameId : "",
    }

    fetch(`/names/check_name_conflicts?${new URLSearchParams(queryParams)}`, {
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
      },
    }).
      then((response) => {
        if (!response.ok) {
          throw new Error(`HTTP status ${response.status}`)
        }
        return response.json()
      }).
      then((names) => {
        if (sequence !== this.requestSequence) return
        this.resultsTarget.innerHTML = this._formatResults(names)
      }).
      catch(() => {
        if (sequence !== this.requestSequence) return
        AntCat.notifyError("Error checking for name conflicts")
      })
  }

  _formatResults(names) {
    if (names.length === 0) {
      return "<h6>Found no similar names <span class='antcat_icon check'></span></h6>"
    }

    const formatted = names.map((name) => {
      const warnAboutHomonym = name.name.toLowerCase() === this.inputTarget.value.toLowerCase().trim()
      const nameOwnerUrl = name.taxon_id ? `/catalog/${name.taxon_id}` : `/protonyms/${name.protonym_id}`

      return `
        <li>
          ${warnAboutHomonym ? '<span class="bold-warning">Homonym</span> ' : ''}
          <a href='${nameOwnerUrl}'>${name.name_html}</a> ${!name.taxon_id ? '(protonym)' : ''}
          <span class='text-sm text-gray-600'>#${name.id}</span>
        </li>
      `
    }).join('')

    return `<h6>Similar names</h6> ${formatted}`
  }
}
