$(function() {
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


function setupAuthorAutocomplete() {
  if (AntCat.testing)
    return;

  $('.author_panel input[type=text]').autocomplete({
    autoFocus: true,
    minLength: 3,
    source: '/authors'
  });
}
