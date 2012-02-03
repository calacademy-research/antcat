$(function() {
  setupAuthorAutocomplete();
})


function setupAuthorAutocomplete() {
  if (testing)
    return;

  $('#q').autocomplete({
    selectFirst: true,
    minLength: 3,
    source: "/authors/all"
  });
}
