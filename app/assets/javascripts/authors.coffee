$ ->
  new AntCat.AuthorForm $('.author_form')

class AntCat.AuthorForm extends AntCat.Form
  constructor: (@element, @options = {}) ->
    @initialize_author_names_section()
    @initialize_events()
    super

  ###### initialization
  initialize_author_names_section: =>
    new AntCat.AuthorNamesSection @element.find('.author_names_section'), parent_form: @

  initialize_events: =>
    @element.bind 'keydown', (event) ->
      return false if event.type is 'keydown' and event.which is $.ui.keyCode.ENTER

  ###### client functions
  add_author_name_panel: ($panel) =>
    @element.find('.author_names').append $panel
