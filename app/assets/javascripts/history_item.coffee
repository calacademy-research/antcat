class AntCat.HistoryItemPanel extends AntCat.Panel
  constructor: (@element, @options) ->
    @options.click_on_display = true
    @options.highlight = true
    super
  create_form: ($element, options) -> new AntCat.HistoryItemForm $element, options
  initialize: (@element) =>
    super
    # make the textarea of the form the same height as the item it's editing
    display_height = @element.find('div.display').height() + 24
    @element.find('.taxt_edit_box').height display_height unless display_height is 0
  on_form_open: =>
    @options.on_form_open() if @options.on_form_open
    @element.find('textarea').focus()
    super
  on_form_close: =>
    @options.on_form_close() if @options.on_form_close
    super

$.fn.history_item_panel = (options = {}) ->
  this.each -> new AntCat.HistoryItemPanel $(this), options

class AntCat.HistoryItemForm extends AntCat.NestedForm
  constructor: (@element, @options = {}) ->
    super
    @element.find('.taxt_editor').taxt_editor()
