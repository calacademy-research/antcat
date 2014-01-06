class AntCat.ReferenceForm extends AntCat.NestedForm

  constructor: (@element, @options = {}) ->
    AntCat.check 'ReferenceForm', '@element', @element
    @options.button_container = '> table > tbody > tr > td.buttons'
    super
    @initialize()

  initialize: =>
    @setup_author_autocomplete()
    @setup_journal_autocomplete()
    @setup_publisher_autocomplete()
    @setup_tabs()

  setup_tabs: =>
    $tabs = @element.find '.tabs'
    $tabs.tabs 'destroy'
    $tabs.find('> ul').remove()
    $list = $('<ul/>').prependTo $tabs
    $tabs.find('.tabbable').each ->
      id = 'A' + Math.random().toString().replace '.', ''
      $list_item = $('<li/>').appendTo $list
      $('<a/>')
        .appendTo($list_item)
        .text($(this).data('title'))
        .attr 'href', '#' + id
      $(this).attr 'id', id
    $tabs.tabs selected: @element.find('.selected_tab').val()

  setup_author_autocomplete: =>
    return if AntCat.testing
    @element.find('.authors').autocomplete
      autoFocus: true
      minLength: 3
      source: (request, result_handler) ->
        search_term = AntCat.ReferenceField.extract_author_search_term(@element.val(), $(@element).getSelection().start)
        if search_term.length >= 3
          $.getJSON "/merge_authors/all", term: search_term, result_handler
        else
          result_handler []
      focus: -> false # don't update the search textbox when the autocomplete item changes
      select: (event, data) ->
        value_and_position = AntCat.ReferenceField.insert_author($(@).val(), $(@).getSelection().start, data.item.value)
        $(@).val value_and_position.string
        $(@).setCaretPos value_and_position.position + 1
        false

  setup_journal_autocomplete: =>
    return if AntCat.testing
    @element.find('.journal').autocomplete
      autoFocus: true,
      source: "/journals",
      minLength: 3

  setup_publisher_autocomplete: =>
    return if AntCat.testing
    @element.find('.publisher').autocomplete
      autoFocus: true,
      source: "/publishers",
      minLength: 3

  before_serialize: ($form, options) =>
    selectedTab = $.trim($('.ui-tabs-selected', $form).text())
    $('#selected_tab', $form).val selectedTab
    true
