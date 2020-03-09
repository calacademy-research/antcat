# TODO: Copy-pasted from `reorder_history_items.coffee`.

# Global variables to make it easy to disable other form buttons
# when interacting with a subform.

AntCat.BUTTONS ||= {}

AntCat.BUTTONS.ADD_REFERENCE_SECTION =      "#add-reference-section-button"
AntCat.BUTTONS.REORDER_REFERENCE_SECTIONS = "#start-reordering-reference-sections"
AntCat.BUTTONS.SAVE_TAXON_FORM =            "#save-taxon-form"

$ ->
  setupReorderButton()

# These elements are from the view.
SORTABLE =      ".reference-sections"
SORTABLE_ITEM = ".reference-section"

# Random class to check if the element already is sortable, because jQuery cannot reliably do it.
IS_SORTABLE = "is-sortable-made-up-class"

setupReorderButton = ->
  $(AntCat.BUTTONS.REORDER_REFERENCE_SECTIONS).on "click", ->
    if $(SORTABLE).hasClass IS_SORTABLE
      disableReordering()
    else
      startReordering()

startReordering = ->
  $(AntCat.BUTTONS.REORDER_REFERENCE_SECTIONS).disableButton()
  $(AntCat.BUTTONS.ADD_REFERENCE_SECTION).disableButton()
  $(AntCat.BUTTONS.SAVE_TAXON_FORM).disable()

  do makeSortable = ->
    $(SORTABLE).addClass IS_SORTABLE
    $(SORTABLE).sortable
      items: SORTABLE_ITEM
      cursor: "move"
      opacity: 0.7
      disabled: false
      start: -> $("#save-reordered-reference-sections").removeClass "disabled"

  do createReorderingControls = ->
    $(SORTABLE).prepend $ """
      <div id="reorder-reference-sections-controls" class="callout center-text">
        Drag and drop reference sections to reorder them.
        <a id="save-reordered-reference-sections" class="btn-saves btn-tiny disabled button">
          Save new order
        </a>
        <a id="cancel-reference-section-reordering" class="btn-nodanger btn-tiny">Cancel</a>
      </div>"""

    $("#save-reordered-reference-sections").on "click", -> saveNewOrder()

    $("#cancel-reference-section-reordering").on "click", ->
      do restorePreviousOrder = -> $(SORTABLE).sortable "cancel"
      disableReordering()

disableReordering = ->
  $(SORTABLE).removeClass IS_SORTABLE
  $(SORTABLE).sortable "disable"

  do destroyReorderingControls = -> $("#reorder-reference-sections-controls").remove()

  $(AntCat.BUTTONS.REORDER_REFERENCE_SECTIONS).enableButton()
  $(AntCat.BUTTONS.ADD_REFERENCE_SECTION).enableButton()
  $(AntCat.BUTTONS.SAVE_TAXON_FORM).undisable()

saveNewOrder = ->
  taxonId = $(SORTABLE).data "taxon-id"

  $.ajax
    type: "POST"
    url: "/taxa/#{taxonId}/reorder_reference_sections"
    dataType: 'json'
    data: $(SORTABLE).sortable "serialize"
    success: ->
      $(SORTABLE).sortable "refreshPositions"
      disableReordering()
    error: (error) ->
      # TODO: Create modal for this and other errors.
      pleaseSee = "Please check the activity feed and see if there is a 'User reordered the reference
        sections...' and let us know via the 'Suggest edit' link or create an issue on GitHub."

      alert """Sorry, something went wrong.

            Error: '#{error.responseText}'

            #{pleaseSee}"""
