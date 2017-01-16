$ ->
  # Adding `.disabled` does this (most likely to a button):
  #   * Changes the appearance to make the element look disabled.
  #   * Actually disables the element.
  #   * And shows the hidden spinner.
  $('.has-spinner').on "click", ->
    $(this).addClass 'disabled'
