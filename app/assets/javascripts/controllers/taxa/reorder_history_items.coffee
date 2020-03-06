# Global variables to make it easy to disable other form buttons
# when interacting with a subform.

AntCat.BUTTONS ||= {}

AntCat.BUTTONS.ADD_HISTORY_ITEM =      "#taxt-editor-add-history-item-button"
AntCat.BUTTONS.REORDER_HISTORY_ITEMS = "#start-reordering-history-items"
AntCat.BUTTONS.SAVE_TAXON_FORM =       "#save-taxon-form"

$ ->
  setupReorderButton()

# These elements are from the view.
SORTABLE =      ".history-items"
SORTABLE_ITEM = ".history-item"

# Random class to check if the element already is sortable, because jQuery cannot reliably do it.
IS_SORTABLE = "is-sortable-made-up-class"

setupReorderButton = ->
  $(AntCat.BUTTONS.REORDER_HISTORY_ITEMS).on "click", ->
    if $(SORTABLE).hasClass IS_SORTABLE
      disableReordering()
    else
      startReordering()

startReordering = ->
  $(AntCat.BUTTONS.REORDER_HISTORY_ITEMS).disableButton()
  $(AntCat.BUTTONS.ADD_HISTORY_ITEM).disableButton()
  $(AntCat.BUTTONS.SAVE_TAXON_FORM).disable()

  do makeSortable = ->
    $(SORTABLE).addClass IS_SORTABLE
    $(SORTABLE).sortable
      items: SORTABLE_ITEM
      cursor: "move"
      opacity: 0.7
      disabled: false
      start: -> $("#save-reordered-history-items").removeClass "disabled"

  do createReorderingControls = ->
    $(SORTABLE).prepend $ """
      <div id="reorder-history-items-controls" class="callout center-text">
        Drag and drop history items to reorder them.
        <a id="save-reordered-history-items" class="btn-saves btn-tiny disabled button">
          Save new order
        </a>
        <a id="cancel-history-item-reordering" class="btn-nodanger btn-tiny">Cancel</a>
      </div>"""

    $("#save-reordered-history-items").on "click", -> saveNewOrder()

    $("#cancel-history-item-reordering").on "click", ->
      do restorePreviousOrder = -> $(SORTABLE).sortable "cancel"
      disableReordering()

disableReordering = ->
  $(SORTABLE).removeClass IS_SORTABLE
  $(SORTABLE).sortable "disable"

  do destroyReorderingControls = -> $("#reorder-history-items-controls").remove()

  $(AntCat.BUTTONS.REORDER_HISTORY_ITEMS).enableButton()
  $(AntCat.BUTTONS.ADD_HISTORY_ITEM).enableButton()
  $(AntCat.BUTTONS.SAVE_TAXON_FORM).undisable()

saveNewOrder = ->
  taxonId = $(SORTABLE).data "taxon-id"

  $.ajax
    type: "POST"
    url: "/taxa/#{taxonId}/reorder_history_items"
    dataType: 'json'
    data: $(SORTABLE).sortable "serialize"
    success: ->
      $(SORTABLE).sortable "refreshPositions"
      disableReordering()
    error: (error) ->
      # TODO: Create modal for this and other errors.
      pleaseSee = "Please check the feed and see if there is a 'User reordered the history
        items...' and let us know via the Feedback link or create an issue on GitHub."

      alert """Sorry, something went wrong.

            Error: '#{error.responseText}'

            #{pleaseSee}"""
