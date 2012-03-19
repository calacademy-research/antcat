window.AntCat or= {}

class AntCat.ReferencePicker
  constructor: ($taxt_edit_box) ->
    @taxt_edit_box = $taxt_edit_box
    alert @taxt_edit_box.control.closest('.inline-form-panel').attr('id')
    this
