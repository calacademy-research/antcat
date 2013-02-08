class AntCat.TaxonForm extends AntCat.Form

  submit: =>
    @start_throbbing()
    @form().submit()

$ ->
  new AntCat.TaxonForm $('.taxon_form'), button_container: '> .buttons_section'
  new AntCat.TaxtEditor $('#headline_notes_taxt_editor')
