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

  @add_history_item: (form) =>
    $template = $('.history_item_template').clone()
    AntCat.log 'HistoryItemPanel add_history_item: no $template' unless $template && $template.size() == 1
    $item = $template.find('.history_item')
    AntCat.log 'HistoryItemPanel add_history_item: no $item' unless $item && $item.size() == 1
    form.add_history_item_panel $item
    $item.history_item_panel(click_on_display: true, parent_form: form, open_immediately: true)

$.fn.history_item_panel = (options = {}) ->
  this.each -> new AntCat.HistoryItemPanel $(this), options

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

      #success: =>
        #@stop_throbbing()
      #error: (jq_xhr, text_status, error_thrown) =>
        #@stop_throbbing()
        #alert "Oh, shoot. It looks like a bug prevented this item from being saved.\n\nPlease report this situation to Mark Wilden (mark@mwilden.com) and we'll fix it.\n\n#{error_thrown}" unless AntCat.testing
