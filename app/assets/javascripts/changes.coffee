class AntCat.ChangeButton
  constructor: (@element) ->
    @element
      .unbutton()
      .button()
      self = @
      @element.click => self.click()

class AntCat.UndoButton extends AntCat.ChangeButton
  create_impacted_taxa_contents: (json_data) =>
    message_start = '''<div id="dialog-undo-impacted-taxa" title="This undo
      will roll back the following changes:"><p><span class="ui-icon ui-icon-alert"
      style="float:left; margin:0 7px 20px 0;"></span><ul>'''

    message = ''
    for item in json_data
      taxon_name = item.name
      change_verb = switch item.change_type
                    when 'create' then "added"
                    when 'update' then "changed"
                    else ''
      username = item.user_name
      timestamp  = item.change_timestamp
      message += "<li>#{taxon_name} #{change_verb} by #{username} on #{timestamp}</li>"

    message_end = '</ul></p></div>'
    "#{message_start}#{message}#{message_end}"

  create_impacted_taxa_dialog: (data,change_id) =>
    @undo_impacted_taxa_message = $(@create_impacted_taxa_contents(data))
    @element.append($(@create_impacted_taxa_contents(data)))
    dialog_box = $("#dialog-undo-impacted-taxa")
    dialog_box.dialog
      resizable: true,
      height: 180,
      width: 720,
      modal: true,
      buttons:
        "Undo!": (a) =>
          $.ajax
            url: "/changes/#{change_id}/undo",
            type: 'put',
            dataType: 'json',
            success: (data) => window.location = '/changes'
            error: (xhr) => debugger
        Cancel: () =>
          dialog_box.dialog("close")

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

$ ->
  $('.undo_button input[type=button]').each -> new AntCat.UndoButton($(this))