class AntCat.ChangeButton
  constructor: (@element) ->
    @element
      .unbutton()
      .button()
    self = @
    @element.click => self.click()

class AntCat.EditButton extends AntCat.ChangeButton
  click: => window.location = @element.data 'edit-location'

class AntCat.ApproveButton extends AntCat.ChangeButton
  click: =>
    return unless confirm 'Are you sure you want to approve this change?'
    change_id = @element.data('change-id')
    url = "/changes/#{change_id}/approve"
    $.ajax
      url:      url,
      type:     'put',
      dataType: 'json',
      success:  (data) => window.location = '/changes'
      error:    (xhr) => debugger

$ ->
  $('.edit_button input[type=button]').each -> new AntCat.EditButton($(this))
  $('.approve_button input[type=button]').each -> new AntCat.ApproveButton($(this))
