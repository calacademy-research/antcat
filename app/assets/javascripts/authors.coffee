$ ->
  new AntCat.AuthorForm $('.author_form')

class AntCat.AuthorForm extends AntCat.Form
  constructor: (@element) ->
    @initialize_author_names_section()
    super

  initialize_author_names_section: =>
    new AntCat.AuthorNamesSection @element.find('.author_names_section'), parent_form: @

  ###### client functions
  add_author_name_panel: ($panel) =>
    @element.find('.author_names').prepend $panel
