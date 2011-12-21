$(function() {
  setupHelp();
  setupButtonHandlers();
})

function setupButtonHandlers() {
  $('.enter_id').live('click', enterID);
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

function setupHelp() {
  $('#q_help').qtip({
    content: "Enter search words, e.g. 'Bolton 2011'. References matching all words will be displayed.",
    show: 'mouseover',
    hide: 'mouseout',
    position: {
      adjust: {y: -7},
      corner: {target: 'topLeft', tooltip: 'bottomRight'}
    }
  });
  $('#match_status_help').qtip({
    content: "'Auto' matches are those for which the score was >= 0.8. 'None' shows references without matches.",
    show: 'mouseover',
    hide: 'mouseout',
    position: {
      adjust: {y: -7},
      corner: {target: 'topLeft', tooltip: 'bottomRight'}
    }
  });
}
