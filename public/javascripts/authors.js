$(function() {
  setupHelp();
  setupAuthorAutocomplete();
  setupCloseLinks();
  $("input[type=text]:last").focus();
})

function setupCloseLinks() {
  $('.author_panel .close_link').click(function(){
    $(this).closest('form').submit();
    return false;
  });
}

function setupHelp() {
  $('.help_icon').qtip({
    content: "Type some letters in the author's name, then choose the name from the list.",
    show: 'mouseover',
    style: { name: 'dark' },
    hide: 'mouseout'
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
