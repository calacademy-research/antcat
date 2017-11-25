class AntCat.HistoryItemsSection
  constructor: (@element, @options = {}) ->
    @initialize()

  initialize: =>
    @initialize_add_button()
    @initialize_panels()

  initialize_add_button: =>
    $add_button = @element.find '.history_items_section_buttons button'; AntCat.log 'HistoryItemsSection constructor: $add_button.size() != 1' unless $add_button.size() == 1
    $add_button.click => @add(); false

  add: =>
    AntCat.HistoryItemPanel.add_history_item @options.parent_form

  initialize_panels: =>
    @element.find('.history_item').history_item_panel(click_on_display: true, parent_form: @options.parent_form)

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
    @make_edit_field_same_height_as_when_displayed()

  make_edit_field_same_height_as_when_displayed: =>
    display_height = @element.find('div.display').height() + 24
    @element.find('.taxt_edit_box').height(display_height) unless display_height is 0

  create_form: ($element, options) -> new AntCat.HistoryItemForm $element, options

  on_form_open: =>
    @options.on_form_open() if @options.on_form_open
    @element.find('textarea').focus()

    $(AntCat.BUTTONS.ADD_HISTORY_ITEM).disableButton()
    $(AntCat.BUTTONS.REORDER_HISTORY_ITEMS).disableButton()
    $(AntCat.BUTTONS.SAVE_TAXON_FORM).disable()
    super

  @add_history_item: (form) =>
    $template = $('.history_item_template').clone()
    AntCat.check 'HistoryItemPanel.add_history_item', '$template', $template
    $item = $template.find('.history_item')
    AntCat.check 'HistoryItemPanel.add_history_item', '$item', $item
    $item.removeClass('history_item_template').addClass('added_history_item')
    form.add_history_item_panel $item
    $item.history_item_panel(click_on_display: true, parent_form: form, open_immediately: true)

#####
class AntCat.HistoryItemForm extends AntCat.NestedForm
  constructor: (@element, @options = {}) ->
    super
    @element.find('.taxt_editor').taxt_editor()

  initialize_buttons: =>
    super
    @buttons.find('.delete').off('click').on('click', @delete)

  enableOtherButtonsAgain: ->
    $(AntCat.BUTTONS.ADD_HISTORY_ITEM).enableButton()
    $(AntCat.BUTTONS.REORDER_HISTORY_ITEMS).enableButton()
    $(AntCat.BUTTONS.SAVE_TAXON_FORM).undisable()

  delete: =>
    return false unless confirm 'Do you want to delete this history item?'
    @start_throbbing()
    url = @form().attr('action')
    $.post url, {_method: 'delete'}, null, 'json'
    @close()
    @options.on_delete() if @options.on_delete
    @element.closest('.history_item').remove()

    @enableOtherButtonsAgain()
    false

  cancel: =>
    $('.added_history_item').remove()

    @enableOtherButtonsAgain()
    super

  close: =>
    $('.added_history_item').removeClass('.added_history_item')

    @enableOtherButtonsAgain()
    super
