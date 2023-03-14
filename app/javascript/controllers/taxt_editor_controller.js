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
