// This makes all textareas with `data-previewable="true"` previewable.
// Can also be invoked manually in case the previewable is not visible on page load.
//
// "Previewable" means markdown in the textarea can be previewed (rendered
// server-side as HTML and return to the client).

/* eslint-disable max-classes-per-file */
(() => {
  const DEFAULT_REFERENCE_BUTTON_ID = "default-reference-button"
  const RECENTLY_USED_REFERENCES_BUTTON_ID = "recently-used-references-button"
  const INSERT_REFERENCE_BUTTON_ID = "insert-reference-button"
  const INSERT_TAXON_BUTTON_ID = "insert-taxon-button"
  const CONVERT_BOLTON_KEYS_BUTTON_ID = "convert-bolton-keys-button"

  const defaultReference = () => {
    const reference = $('#default-reference').get(0)
    const id = reference.getAttribute('data-reference-id')
    const referenceKey = reference.getAttribute('data-reference-key')

    return { id, referenceKey }
  }

  class ExtrasArea {
    constructor(textarea, textareaTab, taxtEditor) {
      this.textarea = textarea
      this.textareaTab = textareaTab
      this.taxtEditor = taxtEditor

      this.createExtrasArea().appendTo(this.textareaTab)
      this.setupDefaultReferenceButton()
      this.setupRecentlyUserReferencesButton()
      this.setupInsertReferenceButton()
      this.setupInsertTaxonButton()

      this.setupConvertBoltonKeysButton()
    }

    createExtrasArea() {
      return $(`<div class="grid grid-cols-2 gap-4">
  <div>
    <button id="${DEFAULT_REFERENCE_BUTTON_ID}" class="btn-default">Default reference</button>
    <button id="${RECENTLY_USED_REFERENCES_BUTTON_ID}" class="btn-default">Recently used references</button>
    <button id="${INSERT_REFERENCE_BUTTON_ID}" class="btn-default">+Reference</button>
    <button id="${INSERT_TAXON_BUTTON_ID}" class="btn-default">+Taxon</button>
    <button id="${CONVERT_BOLTON_KEYS_BUTTON_ID}" class="btn-danger">Convert Bolton keys</button>
  </div>
</div>`)
    }

    setupRecentlyUserReferencesButton() {
      const button = this.textareaTab.find(`#${RECENTLY_USED_REFERENCES_BUTTON_ID}`)

      button.click((event) => {
        event.preventDefault()

        const originalValue = this.textarea.get(0).value

        this.insertAtCaret(this.textarea, "!!")
        const afterValue = this.textarea.get(0).value

        this.restoreIfUnchanged(originalValue, afterValue)
        this.textarea.trigger('click.atwhoInner')
      })
    }

    setupInsertReferenceButton() {
      const button = this.textareaTab.find(`#${INSERT_REFERENCE_BUTTON_ID}`)

      button.click((event) => {
        event.preventDefault()

        const originalValue = this.textarea.get(0).value

        const selectedValue = AntCat.getInputSelection(this.textarea.get(0))
        this.insertAtCaret(this.textarea, `{r${selectedValue}`)
        const afterValue = this.textarea.get(0).value

        this.restoreIfUnchanged(originalValue, afterValue)
        this.textarea.trigger('click.atwhoInner')
      })
    }

    setupInsertTaxonButton() {
      const button = this.textareaTab.find(`#${INSERT_TAXON_BUTTON_ID}`)

      button.click((event) => {
        event.preventDefault()

        const originalValue = this.textarea.get(0).value

        const selectedValue = AntCat.getInputSelection(this.textarea.get(0))
        this.insertAtCaret(this.textarea, `{t${selectedValue}`)
        const afterValue = this.textarea.get(0).value

        this.restoreIfUnchanged(originalValue, afterValue)
        this.textarea.trigger('click.atwhoInner')
      })
    }

    restoreIfUnchanged(originalValue, afterValue) {
      this.textarea.off('hidden.atwho')
      this.textarea.on('hidden.atwho', () => {
        if (this.textarea.get(0).value === afterValue) {
          this.textarea.get(0).value = originalValue
        }
      })
    }

    setupDefaultReferenceButton() {
      const reference = defaultReference()
      const button = this.textareaTab.find(`#${DEFAULT_REFERENCE_BUTTON_ID}`)

      if (!reference?.id) {
        button.get(0).setAttribute("disabled", "disabled")
        return
      }

      button.get(0).textContent = reference.referenceKey
      button.click((event) => {
        event.preventDefault()
        this.insertAtCaret(this.textarea, `{ref ${reference.id}}: `)
      })
    }

    setupConvertBoltonKeysButton() {
      const button = this.textareaTab.find(`#${CONVERT_BOLTON_KEYS_BUTTON_ID}`)

      button.click((event) => {
        event.preventDefault()

        $.ajax({
          url: "/panel/bolton_keys_to_ref_tags.json",
          type: "POST",
          data: { bolton_content: this.textarea.get(0).value },
          dataType: "html",
          success: (parsedContent) => {
            this.textarea.get(0).value = parsedContent
            this.taxtEditor.renderPreview()
            AntCat.notifySuccess("Converted Bolton keys")
          },
          error: () => AntCat.notifyError("Error parsing Bolton keys"),
        })
      })
    }

    // Via https://stackoverflow.com/questions/28873350
    insertAtCaret(jQueryElement, valueToInsert) {
      const element = jQueryElement.first().get(0)

      if (document.selection) { // For browsers like Internet Explorer.
        element.focus()
        const selection = document.selection.createRange()
        selection.text = valueToInsert
        element.focus()
      } else if (element.selectionStart || element.selectionStart === '0' || element.selectionStart === 0) { // Firefox and Webkit-based.
        const startPos = element.selectionStart
        const endPos = element.selectionEnd
        const { scrollTop } = element
        element.value = element.value.substring(0, startPos) + valueToInsert + element.value.substring(endPos, element.value.length)
        element.focus()
        element.selectionStart = startPos + valueToInsert.length
        element.selectionEnd = startPos + valueToInsert.length
        element.scrollTop = scrollTop
      } else {
        element.value += valueToInsert
        element.focus()
      }
    }
  }

  class MakePreviewable {
    constructor(textarea, justRender = false) {
      this.textarea = textarea

      if (this.isAlreadyPreviewable() && justRender) {
        if (this.textarea.get(0).value === "") return
        this.renderPreview()
        return
      }

      if (this.isAlreadyPreviewable()) return

      this.wrapInPreviewArea()
      this.setupPreviewLink()

      if (this.textarea.get(0).getAttribute('data-use-extras')) {
        new ExtrasArea(this.textarea, this.textarea.parent().parent().parent(), this) // eslint-disable-line no-new
      }

      if (this.textarea.is(":visible") && this.textarea.get(0).value !== "") {
        this.renderPreview()
      }

      // Resize textareas according to content (works only for visible text areas).
      this.textarea.get(0).style.height = `${this.textarea[0].scrollHeight}px`
    }

    isAlreadyPreviewable() {
      return this.textarea.get(0).parentNode.classList.contains("is-already-previewable")
    }

    wrapInPreviewArea() {
      // Create new preview area (tabs) and insert after textarea, and tabify.
      const title = this.textarea.get(0).getAttribute('data-previewable-title') || "Text"
      const previewArea = this.createPreviewArea(title)
      previewArea.insertAfter(this.textarea)

      // Move textarea inside the first tab of the preview area.
      this.textarea.detach().prependTo(previewArea.find(".preview-editable"))
    }

    createPreviewArea(title) {
      return $(`<div class="preview-area mb-4">
  <div class="grid grid-cols-2 gap-4">
    <div>${title}</div>
    <div>
      Preview
      <button class="btn-neutral preview-link">Rerender preview</button>
    </div>
  </div>
  <div class="grid grid-cols-2 gap-4">
    <div class="preview-editable is-already-previewable [&_textarea]:text-lg"></div>
    <div class="preview-previewable p-2 border border-gray-300 min-h-[4rem]"></div>
  </div>
</div>`)
    }

    setupPreviewLink() {
      const previewArea = this.textarea.parent().parent().parent()
      previewArea.find(".preview-link").click((event) => {
        event.preventDefault()
        this.renderPreview()
      })
    }

    renderPreview() {
      const tab = this.textarea.parent().parent().find(".preview-previewable")

      const toParse = this.textarea.get(0).value
      const formatTypeFields = this.textarea.get(0).getAttribute('data-format-type-fields')

      if (toParse === "") {
        tab.get(0).innerHTML = "No content. Try this: <code>{tax 430207}</code>"
        return
      }

      $.ajax({
        url: "/markdown/preview",
        type: "POST",
        data: {
          text: toParse,
          format_type_fields: formatTypeFields,
        },
        dataType: "html",
        success: (html) => {
          tab.get(0).innerHTML = html
          window.setupLinkables()
        },
        error: () => {
          tab.get(0).textContent = "Error rendering preview"
        },
      })
    }
  }

  $.fn.makePreviewable = function () {
    return new MakePreviewable(this)
  }

  // Super dirty.
  $.fn.renderUnrenderedPreviewableHack = function () {
    return new MakePreviewable(this, true)
  }

  AntCat.makeAllPreviewable = () => $("textarea[data-previewable]").each(function () {
    $(this).makePreviewable()
  })

  $(() => {
    AntCat.makeAllPreviewable()
  })
})()
