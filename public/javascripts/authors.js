$(function() {
  setupHelp();
  setupAuthorAutocomplete();
  $("input[type=text]:last").focus();
})

function setupHelp() {
  $('.q.help_icon').qtip({
    content: "Type some letters in the author's name, then choose the name from the list.",
    show: 'mouseover',
    hide: 'mouseout',
  });
}

function setupAuthorAutocomplete() {
  if (testing)
    return;

  $('.author_panel input[type=text]').autocomplete({
    selectFirst: true,
    minLength: 3,
    source: "/authors/all"
  });
}
