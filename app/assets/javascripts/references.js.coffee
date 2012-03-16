setupSearch = ->
  $("#search form").submit ->
    inp = $("#q", $(this))
    inp.blur()
    string = inp.attr("value")
    string += " "  unless string.match(RegExp(" $"))
    string.replace /'/, "\""
    inp.attr "value", string

  $("#search form").keypress (e) ->
    if (e.which and e.which is 13) or (e.keyCode and e.keyCode is 13)
      $("button[type=submit].default").click()
      false
    else
      true

  setupSearchBox $("#search_selector option:selected").text()
  $("#search_selector").change ->
    new_type = $("#search_selector option:selected").text()
    removeAdvancedSearchAuthorAutocomplete()  if new_type is "Search for"
    setupSearchBox new_type
setupSearchBox = (selector_text) ->
  if selector_text is "Search for"
    setHelpIconText "Enter search words (including author names), a year, a year range or an ID. Words are searched for in the title, author names, journal name, publisher name, citation, cite code, and notes.)"
  else
    setupAdvancedSearchAuthorAutocomplete()
    setHelpIconText "Start typing an author's name, then choose it from the list and press Enter. Repeat for additional author names. Then press Enter to find references by all those authors, including references by aliases of those authors. For example, searching for Radchenko, A.G. will also find references by Radchenko, A., Radtchenko, A. G., and Radtschenko, A. G."
setHelpIconText = (text) ->
  setupQtip ".help_icon", text,
    style:
      width: 600

    position:
      adjust:
        y: -7

      corner:
        target: "topLeft"
        tooltip: "bottomRight"
setupDisplays = ->
  setupIcons()
setupIcons = ->
  setupIconVisibility()
  if AntCat.user_can_edit
    setupIconHighlighting()
    setupIconClickHandlers()
setupIconVisibility = ->
  $(".icon").hide()  if not AntCat.testing or not AntCat.user_can_edit
  unless AntCat.user_can_edit
    $(".reference").live("mouseenter", ->
      $(".icon", $(this)).show()  unless isEditing()
    ).live "mouseleave", ->
      $(".icon").hide()

setupIconHighlighting = ->

setupIconClickHandlers = ->
  $(".icon.edit").live "click", editReference
  $(".icon.add").live "click", insertReference
  $(".icon.copy").live "click", copyReference
  $(".icon.delete").live "click", deleteReference
setupEdits = ->
  $(".reference_edit").hide()
  $(".reference_edit .submit").live "click", submitReferenceEdit
  $(".reference_edit .cancel").live "click", cancelReferenceEdit
  $(".reference_edit .delete").live "click", deleteReference
editReference = ->
  return false  if isEditing()
  $reference = $(this).closest(".reference")
  saveReference $reference
  showReferenceEdit $reference,
    showDeleteButton: true

  false
deleteReference = ->
  $reference = $(this).closest(".reference")
  $reference.addClass "about_to_be_deleted"
  if confirm(delete_confirmation_message)
    $.post $reference.find("form").attr("action"),
      _method: "delete"
    , (data) ->
      if data.success
        $reference.closest("tr").remove()
        removeSavedReference()
      else
        alert data.message
  else
    $reference.removeClass "about_to_be_deleted"
  false
addReference = ->
  addOrInsertReferenceEdit null
  false
insertReference = ->
  addOrInsertReferenceEdit $(this).closest(".reference")
  false
copyReference = ->
  $rowToCopyFrom = $(this).closest("tr.reference_row")
  $newRow = $rowToCopyFrom.clone(true)
  $rowToCopyFrom.after $newRow
  $newReference = $(".reference", $newRow)
  $newReference.attr "id", "reference_"
  $("form", $newReference).attr "action", "/references"
  $("[name=_method]", $newReference).attr "value", "post"
  clearFieldsThatShouldntBeCopied $newReference
  showReferenceEdit $newReference
  false
clearFieldsThatShouldntBeCopied = ($reference) ->
  $("#reference_document_attributes_id", $reference).remove()
  $("#reference_document_attributes_url", $reference).attr "value", ""
  $("#reference_document_attributes_public", $reference).attr "checked", ""
  $("#reference_date", $reference).attr "value", ""
  $("#reference_cite_code", $reference).attr "value", ""
addOrInsertReferenceEdit = ($reference) ->
  $referenceTemplateRow = $(".reference_template_row")
  $newReferenceRow = $referenceTemplateRow.clone(true)
  $newReferenceRow.removeClass("reference_template_row").addClass "reference_row"
  $(".reference_template", $newReferenceRow).removeClass("reference_template").addClass "reference"
  unless $reference?
    $(".references").prepend $newReferenceRow
  else
    $reference.closest("tr").after $newReferenceRow
  $newReference = $(".reference", $newReferenceRow)
  showReferenceEdit $newReference
saveReference = ($reference) ->
  $("#saved_reference").remove()
  $reference.clone(true).attr("id", "saved_reference").appendTo("body").hide()
restoreReference = ($reference) ->
  id = $reference.attr("id")
  $reference.replaceWith $("#saved_reference")
  $("#saved_reference").attr("id", id).show()
removeSavedReference = ->
  $("#saved_reference").remove()
showReferenceEdit = ($reference, options) ->
  options = {}  unless options
  $(".reference_display", $reference).hide()
  $(".icon").hide()  unless AntCat.testing
  $edit = $(".reference_edit", $reference)
  $(".delete", $edit).hide()  unless options.showDeleteButton
  setupTabs $reference
  setupReferenceEditAuthorAutocomplete $reference
  setupReferenceEditJournalAutocomplete $reference
  setupReferenceEditPublisherAutocomplete $reference
  $edit.show()
  $("#reference_author_names_string", $edit)[0].focus()
setupTabs = ($reference) ->
  id = $reference.attr("id")
  selected_tab = $(".selected_tab", $reference).val()
  $(".tabs .article-tab", $reference).attr "href", "#reference_article" + id
  $(".tabs .article-tab-section", $reference).attr "id", "reference_article" + id
  $(".tabs .book-tab", $reference).attr "href", "#reference_book" + id
  $(".tabs .book-tab-section", $reference).attr "id", "reference_book" + id
  $(".tabs .nested-tab", $reference).attr "href", "#reference_nested" + id
  $(".tabs .nested-tab-section", $reference).attr "id", "reference_nested" + id
  $(".tabs .unknown-tab", $reference).attr "href", "#reference_unknown" + id
  $(".tabs .unknown-tab-section", $reference).attr "id", "reference_unknown" + id
  $(".tabs", $reference).tabs selected: selected_tab
submitReferenceEdit = ->
  $(this).closest("form").ajaxSubmit
    beforeSerialize: beforeSerialize
    beforeSubmit: setupSubmit
    success: updateReference
    dataType: "json"

  false
beforeSerialize = ($form, options) ->
  selectedTab = $.trim($(".ui-tabs-selected", $form).text())
  $("#selected_tab", $form).val selectedTab
  true
setupSubmit = (formData, $form, options) ->
  $spinnerElement = $("button", $form).parent()
  $spinnerElement.spinner
    position: "left"
    img: "/assets/ui-anim_basic_16x16.gif"

  ""
  $("input", $spinnerElement).attr "disabled", "disabled"
  $("button", $spinnerElement).attr "disabled", "disabled"
  true
updateReference = (data, statusText, xhr, $form) ->
  $reference = $("#reference_" + (if data.isNew then "" else data.id))
  $edit = $(".reference_edit", $reference)
  $spinnerElement = $("button", $edit).parent()
  $("input", $spinnerElement).attr "disabled", ""
  $("button", $spinnerElement).attr "disabled", ""
  $spinnerElement.spinner "remove"
  $reference.parent().html data.content
  unless data.success
    $reference = $("#reference_" + (if data.isNew then "" else data.id))
    showReferenceEdit $reference
    return
  $reference = $("#reference_" + data.id)
  $(".reference_edit", $reference).hide()
  $(".reference_display", $reference).show().effect "highlight", {}, 3000
cancelReferenceEdit = ->
  $reference = $(this).closest(".reference")
  unless $reference.attr("id") is "reference_"
    id = $reference.attr("id")
    restoreReference $reference
    $reference = $("#" + id)
    $(".reference_display", $reference).show().effect "highlight", {}, 3000
  false
isEditing = ->
  $(".reference_edit").is ":visible"
$ ->
  setupSearch()
  setupDisplays()
  setupEdits()  if AntCat.user_can_edit
