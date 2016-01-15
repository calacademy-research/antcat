class AntCat.ChangeButton
  constructor: (@element) ->
    @element
    .unbutton()
    .button()
    self = @
    @element.click => self.click()

class AntCat.UndoButton extends AntCat.ChangeButton
  create_impacted_taxa_contents: (json_data) =>
    message = '<div id="dialog-undo-impacted-taxa" title="This undo will roll back the following changes:"><p>
       <span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 20px 0;"></span>'
    message = message + '<ul>'
    for i in [1..json_data.length] by 1
      j = i - 1
      item = json_data[j]

      message = message + '<li>' + item.name
      if(item.change_type == 'create')
        message = message + " added"
      else if(item.change_type == 'update')
        message = message + " changed "
      message = message + " by " +  item.user_name + " on " + item.change_timestamp
      message = message + '</li>'
    message = message + '</ul>'
    message = message + '</div></p></div>'
    message

  create_impacted_taxa_dialog: (data,change_id) =>
    @undo_impacted_taxa_message = $(@create_impacted_taxa_contents(data))
    @element.append($(@create_impacted_taxa_contents(data)))
    dialog_box = $("#dialog-undo-impacted-taxa")
    dialog_box.dialog({
      resizable: true,
      height: 180,
      width: 720,
      modal: true,
      buttons: {
        "Undo!": (a) =>
          $.ajax
            url: "/changes/#{change_id}/undo",
            type: 'put',
            dataType: 'json',
            success: (data) => window.location = '/changes'
            error: (xhr) => debugger
        Cancel: () =>
          dialog_box.dialog("close")
        }
    })

  click: =>
    change_id = @element.data('undo-id')
    url = "/changes/#{change_id}/undo_items"
    $.ajax
      url: url,
      type: 'get',
      dataType: 'json',
      success: (data) =>
        @create_impacted_taxa_dialog(data, change_id)
      async: false,
      error: (xhr) => debugger

class AntCat.ApproveAllButton extends AntCat.ChangeButton
  click: =>
    return unless confirm 'Are you sure you want to approve all changes?'
    url = "/changes/approve_all"
    $.ajax
      url: url,
      type: 'put',
      dataType: 'json',
      success: (data) => window.location = '/changes'
      error: (xhr) => debugger

class AntCat.ApproveButton extends AntCat.ChangeButton
  click: =>
    return unless confirm 'Are you sure you want to approve this change?'
    change_id = @element.data('change-id')
    url = "/changes/#{change_id}/approve"
    $.ajax
      url: url,
      type: 'put',
      dataType: 'json',
      success: (data) => window.location = '/changes'
      error: (xhr) => debugger

$ ->
  $('.undo_button input[type=button]').each -> new AntCat.UndoButton($(this))
  $('.approve_button input[type=button]').each -> new AntCat.ApproveButton($(this))
  $('.approve_all_button input[type=button]').each -> new AntCat.ApproveAllButton($(this))
