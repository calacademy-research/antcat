class AntCat.HistoryItemPanel extends AntCat.Panel
  element_class: 'history_item'
  create_form: ($element, options) -> new AntCat.HistoryItemForm $element, options
  setup_form: =>
    # make the textarea of the form the same height as the item it's editing
    display_height = @element.find('div.display').height()
    @element.find('.taxt_edit_box').height display_height + 30

$.fn.history_item_panel = (options = {}) ->
  return this.each -> new AntCat.HistoryItemPanel $(this), options

class AntCat.HistoryItemForm extends AntCat.Form

  original_value_key: 'original_value'

  save_form_values: =>
    $taxt_edit_box = @element.find 'textarea'
    $taxt_edit_box.data @original_value_key, $taxt_edit_box.val()

  restore_form_values: =>
    $taxt_edit_box = @element.find 'textarea'
    $taxt_edit_box.val $taxt_edit_box.data original_value_key
