class AntCat.HistoryItemPanel extends AntCat.Panel
  element_class: 'history_item'
  @element_class: 'history_item'
  create_form: ($element, options) -> new AntCat.HistoryItemForm $element, options
  initialize: ($element) =>
    super
    # make the textarea of the form the same height as the item it's editing
    display_height = @element.find('div.display').height()
    @element.find('.taxt_edit_box').height display_height unless display_height is 0
  on_form_open: =>
    @options.on_form_open()
    super

$.fn.history_item_panel = (options = {}) ->
  this.each -> new AntCat.HistoryItemPanel $(this), options

class AntCat.HistoryItemForm extends AntCat.Form

  constructor: ->
    super
    @element
      .find('textarea')
        .taxt_edit_box()
        .end()
      .find('.taxt_edit_box').first()
        .focus()
