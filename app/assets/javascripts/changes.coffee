class AntCat.ChangeButton
  constructor: (@element) ->
    self = this
    $('#approve_button')
      .unbutton()
      .button()
      .click (target) => self.approve()

  approve: =>
    return unless @confirm 'Are you sure you want to approve this change?'
    change_id = @element.data('change-id')
    url = "/changes/#{change_id}/approve"
    $.ajax url: url, type: 'put', dataType: 'json',
      success: (data) =>
      error: (xhr) => debugger
    window.location = "/changes"

  confirm: (question) =>
    #$row = $(button).closest '.synonym_row'
    #$row.addClass 'confirming'
    #result = confirm question
    #$row.removeClass 'confirming'
    #result
    true

$ ->
  $('.approve_button button').each -> new AntCat.ChangeButton($(this))
