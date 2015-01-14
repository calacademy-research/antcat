class AntCat.ChangeButton
  constructor: (@element) ->
    @element
      .unbutton()
      .button()
    self = @
    @element.click => self.click()

class AntCat.EditButton extends AntCat.ChangeButton
  click: => window.location = @element.data 'edit-location'

class AntCat.UndoButton extends AntCat.ChangeButton
  impacted_taxa_html: (json_data) =>
    'Are you sure you want to undo this change? This will remove the change from antcat forever! joe'


  impacted_taxa: (json_data, change_id) =>
    html = @impacted_taxa_html(json_data)
    return unless confirm html
    url = "/changes/#{change_id}/undo"
    $.ajax
      url:      url,
      type:     'put',
      dataType: 'json',
      success:  (data) => window.location = '/changes'
      error:    (xhr) => debugger

  click: =>
    change_id = @element.data('undo-id')
    url = "/changes/#{change_id}/undo_items"
    $.ajax
      url: url,
      type: 'get',
      dataType: 'json',
      success: (data) =>
        @impacted_taxa(data, change_id)
      async: false,
      error: (xhr) => debugger

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
  $('.undo_button input[type=button]').each -> new AntCat.UndoButton($(this))
  $('.approve_button input[type=button]').each -> new AntCat.ApproveButton($(this))
