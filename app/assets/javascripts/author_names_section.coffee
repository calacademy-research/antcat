class AntCat.AuthorNamesSection
  constructor: (@element, @options = {}) ->
    @initialize()

  initialize: =>
    @initialize_add_button()
    @initialize_panels()

  initialize_add_button: =>
    $add_button = @element.find '.author_names_section_buttons button'; AntCat.check 'AuthorNamesSection constructor: $add_button.size() != 1' unless $add_button.size() == 1
    $add_button.click => @add(); false

  add: =>
    AntCat.AuthorNamePanel.add_author_name @options.parent_form

  initialize_panels: =>
    @element.find('.author_name').author_name_panel(click_on_display: false, parent_form: @options.parent_form)

#####
$.fn.author_name_panel = (options = {}) ->
  this.each -> new AntCat.AuthorNamePanel $(this), options

class AntCat.AuthorNamePanel extends AntCat.Panel
  constructor: (@element, @options) ->
    @options.click_on_display = true
    @options.highlight = true
    super

  initialize: (@element) =>
    super

  create_form: ($element, options) -> new AntCat.AuthorNameForm $element, options

  on_form_open: =>
    @options.on_form_open() if @options.on_form_open
    @element.find('input[type=text]').focus()
    super

  @add_author_name: (form) =>
    $template = $('.author_name_template').clone(); AntCat.check 'AuthorNamePanel.add_author_name', '$template', $template
    $item = $template.find('.author_name'); AntCat.check 'AuthorNamePanel.add_author_name', '$item', $item
    $item.removeClass('author_name_template').addClass('added_author_name')
    form.add_author_name_panel $item
    $item.author_name_panel(click_on_display: true, parent_form: form, open_immediately: true)
#####
class AntCat.AuthorNameForm extends AntCat.NestedForm
  constructor: (@element, @options = {}) ->
    super

  initialize_buttons: =>
    super
    @buttons.find('.delete').off('click').on('click', @delete)

  delete: =>
    return false unless confirm 'Do you want to delete this author name?'
    @start_throbbing()
    url = @form().attr('action')
    $.post url, {_method: 'delete'}, null, 'json'
    @close()
    @options.on_delete() if @options.on_delete
    @element.closest('.author_name').remove()
    false

  cancel: =>
    $('.added_author_name').remove()
    super

  close: =>
    $('.added_author_name').removeClass('.added_author_name')
    super
