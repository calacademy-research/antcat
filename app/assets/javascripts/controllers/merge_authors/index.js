$(function() {
  setupAuthorAutocomplete();
  setupCloseLinks();
  $("input[type=text]:last").focus();
})

function setupCloseLinks() {
  $('.close_link').click(function(){
    $(this).closest('form').submit();
    return false;
  });
}

function setupAuthorAutocomplete() {
  if (AntCat.testing)
    return;

  $('input[type=text]').autocomplete({
    autoFocus: true,
    minLength: 3,
    source: '/authors/autocomplete'
  });
}
