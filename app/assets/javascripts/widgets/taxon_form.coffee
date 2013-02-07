class AntCat.TaxonForm extends AntCat.Form

  submit: =>
    @start_throbbing()
    @form().submit()
