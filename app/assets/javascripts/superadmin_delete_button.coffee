$ ->
  $('#delete_button')
    .click =>
      taxon_id = $('#delete_button').data('taxon-id')
      url = "/catalog/delete_impact_list/" + taxon_id
      $.ajax
        url: url,
        type: 'get',
        dataType: 'json',
        success: (data) =>
          confirm_delete_dialog(data,$('#delete_button').data('delete-location'))
        async: false,
        error: (xhr) => debugger

confirm_delete_dialog = (data, destination) ->
  @delete_message = $('#delete_message')
  message = '<div id="delete-modal" title="This delete will remove the following taxa:"><p>
         <span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 20px 0;"></span>'

  message = message + '<ul>'
  for i in [1..data.length] by 1
    j = i - 1
    item = data[j]
    for k,v of item
      if(k != '__proto__')
        item = v
    message = message + '<li>' + item.name_html_cache + ", " + item.authorship_string + ": " + "created at: " + item.created_at

    message = message + '</li>'
  message = message + '</ul>'

  message = message + '</div></p></div>'
  @delete_message.append(message)
  dialog_box = $("#delete-modal")
  dialog_box.dialog
    resizable: true,
    height: 280,
    width: 720,
    modal: true,
    buttons:
      "Delete?": (a) =>
        $.ajax
          url: destination,
          type: 'DELETE',
          dataType: 'json',
          success: (data) -> window.location.href = "/"
          async: false,
          error: (xhr) => debugger
      "Cancel":
        id: "Cancel-Dialog"
        text: "Cancel"
        click: =>
          dialog_box.dialog("close")
  $('.delete_message').show()