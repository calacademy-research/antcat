$ ->
  makeSortable()

SORTABLE = "#sortable"
SORTABLE_ITEM = ".sortable-item"

makeSortable = ->
  $(SORTABLE).sortable
    items: SORTABLE_ITEM
    cursor: "move"
    opacity: 0.7
    disabled: false

  $('#reorder-form').on 'submit', (_event) ->
    newOrder = $(SORTABLE).sortable("toArray")
    $("#new-order").val(newOrder)
