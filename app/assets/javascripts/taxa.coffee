class AntCat.TaxonForm extends AntCat.Form

  submit: =>
    @start_throbbing()
    @form().submit()

  cancel: =>
    id = @form().attr('action').match(/\d+/)[0]
    window.location = "/catalog/#{id}"

$ ->
  new AntCat.TaxonForm $('.taxon_form'), button_container: '> .buttons_section'
  new AntCat.TaxtEditor $('#headline_notes_taxt_editor'), parent_buttons: '.buttons_section'
  new AntCat.NameField $('#protonym_name_field'), parent_buttons: '.buttons_section'
  new AntCat.TaxtEditor $('#type_taxt_editor'), parent_buttons: '.buttons_section'
