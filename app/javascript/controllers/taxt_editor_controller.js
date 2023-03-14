import ApplicationController from "./application_controller"

export default class extends ApplicationController {
  static targets = [
    "editor",
    "presenter",
    "textarea",
    "content", // TODO: Naming?
    "editSummaryInput",
  ]

  static values = {
    url: String,
  }

  connect() {
    this.container = this.element
  }

  saveHistoryItem() {
    const jsonData = {
      history_item: {
        taxt:               this.container.querySelector('textarea#taxt')?.value,
        subtype:            this.container.querySelector('select[name=subtype]')?.value,
        picked_value:       this.container.querySelector('select[name=picked_value]')?.value,
        text_value:         this.container.querySelector('input[name=text_value]')?.value,
        object_protonym_id: this.container.querySelector('[name=object_protonym_id]')?.value,
        object_taxon_id:    this.container.querySelector('[name=object_taxon_id]')?.value,
        reference_id:       this.container.querySelector('[name=reference_id]')?.value,
        pages:              this.container.querySelector('input[name=pages]')?.value,
      },
      edit_summary: this.editSummary,
    }

    fetch(this.urlValue, {
      method: "PUT",
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
        "X-CSRF-Token": this.csrfToken(),
      },
      body: JSON.stringify(jsonData),
    }).
      then((response) => {
        if (!response.ok) {
          throw new Error(`HTTP status ${response.status}`)
        }
        return response.json()
      }).
      then((json) => {
        AntCat.notifySuccess("Updated history item")
        this.container.outerHTML = json.content
        window.setupLinkables()
        window.setupTaxtEditors()
      }).
      catch((error) => { alert(error) })
  }

  saveReferenceSection() {
    const jsonData = {
      reference_section: {
        title_taxt:      this.container.querySelector('textarea#title_taxt').value,
        subtitle_taxt:   this.container.querySelector('textarea#subtitle_taxt').value,
        references_taxt: this.container.querySelector('textarea#references_taxt').value,
      },
      edit_summary: this.editSummary,
    }

    fetch(this.urlValue, {
      method: "PUT",
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
        "X-CSRF-Token": this.csrfToken(),
      },
      body: JSON.stringify(jsonData),
    }).
      then((response) => {
        if (!response.ok) {
          throw new Error(`HTTP status ${response.status}`)
        }
        return response.json()
      }).
      then((json) => {
        AntCat.notifySuccess("Updated reference section")
        this.container.outerHTML = json.content
        window.setupLinkables()
        window.setupTaxtEditors()
      }).
      catch((error) => { alert(error) })
  }

  // TODO: This leaves empty HTML elements in some places.
  delete(event) {
    event.preventDefault()

    if (!confirm("Are you sure?")) { // eslint-disable-line no-restricted-globals
      return
    }

    const jsonData = {
      edit_summary: this.editSummary,
    }

    fetch(this.urlValue, {
      method: "DELETE",
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
        "X-CSRF-Token": this.csrfToken(),
      },
      body: JSON.stringify(jsonData),
    }).
      then((response) => {
        if (!response.ok) {
          throw new Error(`HTTP status ${response.status}`)
        }
        return response
      }).
      then((_response) => {
        AntCat.notifySuccess("Deleted item")
        this.container.remove()
      }).
      catch((error) => { alert(error) })
  }

  cancel() {
    this.exitEditMode()
  }

  // TOOD: This does not take into account `format_type_fields` after pressing "OK".`
  ok(event) {
    event.preventDefault()

    const jsonData = {
      text: this.textareaTarget.value,
    }

    fetch("/markdown/preview", {
      method: "POST",
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
        "X-CSRF-Token": this.csrfToken(),
      },
      body: JSON.stringify(jsonData),
    }).
      then((response) => {
        if (!response.ok) {
          throw new Error(`HTTP status ${response.status}`)
        }
        return response.text()
      }).
      then((renderedMarkdown) => {
        this.contentTarget.innerHTML = renderedMarkdown
        this.exitEditMode()
      }).
      catch((error) => { alert(error) })
  }

  exitEditMode() {
    this.editorTarget.classList.add("hidden")
    this.presenterTarget.classList.remove("hidden")
  }

  get editSummary() {
    return this.editSummaryInputTarget.value
  }
}
