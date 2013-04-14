class AntCat.HistoryItemsSection
  constructor: (@element, @options = {}) ->
    @initialize()

  initialize: =>
    $add_button = @element.find '.history_items_section_buttons button'
    AntCat.log 'HistoryItemsSection constructor: $add_button.size() != 1' unless $add_button.size() == 1
    $add_button.click => @add(); false
    @element.find('.history_item').history_item_panel(click_on_display: true, parent_form: @options.parent_form)

  add: =>
    AntCat.HistoryItemPanel.add_history_item @options.parent_form

#####
$.fn.history_item_panel = (options = {}) ->
  this.each -> new AntCat.HistoryItemPanel $(this), options

class AntCat.HistoryItemPanel extends AntCat.Panel
  constructor: (@element, @options) ->
    @options.click_on_display = true
    @options.highlight = true
    super

  initialize: (@element) =>
    super
    # make the textarea of the form the same height as the item it's editing
    display_height = @element.find('div.display').height() + 24
    @element.find('.taxt_edit_box').height(display_height) unless display_height is 0

  create_form: ($element, options) -> new AntCat.HistoryItemForm $element, options

  on_form_open: =>
    @options.on_form_open() if @options.on_form_open
    @element.find('textarea').focus()
    super

  @add_history_item: (form) =>
    $template = $('.history_item_template').clone()
    AntCat.log 'HistoryItemPanel add_history_item: no $template' unless $template && $template.size() == 1
    $item = $template.find('.history_item')
    AntCat.log 'HistoryItemPanel add_history_item: no $item' unless $item && $item.size() == 1
    $item.addClass('not_history_item_template').removeClass('history_item_template').addClass('added_history_item')
    form.add_history_item_panel $item
    $item.history_item_panel(click_on_display: true, parent_form: form, open_immediately: true)

#####
class AntCat.HistoryItemForm extends AntCat.NestedForm
  constructor: (@element, @options = {}) ->
    super
    @element.find('.taxt_editor').taxt_editor()

  initialize_buttons: =>
    super
    @buttons.find('.delete')
      .off('click')
      .on('click', @delete).end()

  delete: =>
    return false unless confirm 'Do you want to delete this history item?'
    @start_throbbing()
    url = @form().attr('action')
    $.post url, {_method: 'delete'}, null, 'json'
    @close()
    @options.on_delete() if @options.on_delete
    @element.closest('.history_item').remove()
    false

  cancel: =>
    $('.added_history_item').remove()
    super

  close: =>
    $('.added_history_item').removeClass('.added_history_item')
    super
