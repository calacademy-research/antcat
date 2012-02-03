$(function() {
  setupHelp();
  setupAuthorAutocomplete();
})

function setupHelp() {
  $('.q.help_icon').qtip({
    content: "Start entering an author name, then press Enter to choose from the list. Then press Enter to search for the chosen name",
    show: 'mouseover',
    hide: 'mouseout',
  });
}

function setupAuthorAutocomplete() {
  if (testing)
    return;

  $('#q').autocomplete({
    selectFirst: true,
    minLength: 3,
    source: "/authors/all"
  });
}
