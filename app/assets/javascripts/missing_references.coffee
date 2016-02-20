$ ->
  new AntCat.MissingReferencesForm $('.missing_references_form-js-hook'),
    button_container: '> .fields_section .buttons_section'

class AntCat.MissingReferencesForm extends AntCat.Form
  constructor: (@element, @options = {}) ->
    new AntCat.ReferenceField $('#replacement_id_field'), value_id: 'replacement_id', parent_form: @
    @element.bind 'keydown', (event) ->
      return false if event.type is 'keydown' and event.which is $.ui.keyCode.ENTER
    super

  submit: =>
    super if confirm 'Do you want to replace this reference? It can take a minute or two.'

  cancel: =>
    window.location = '/missing_references'
