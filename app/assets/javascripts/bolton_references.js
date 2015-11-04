$(function() {
  setupButtonHandlers();
})

function setupButtonHandlers() {
  $('body').on('click','.enter_id', enterID);
}

enterIDInput = '';

function enterID() {
  enterIDInput = prompt("AntCat ID", enterIDInput);
  if (!enterIDInput || enterIDInput == "")
    return false;
  $form = $(this).closest('form');
  action = $form.attr('action')
  $form.attr('action', action.replace('_id_', enterIDInput));
}


