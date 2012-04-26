class AntCat.TaxonForm extends AntCat.Form
  constructor: ->
    super
    @element.show()
    @open()

  cancel: =>
    @element.hide()
    @close()
    super
