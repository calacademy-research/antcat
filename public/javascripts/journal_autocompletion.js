function setupJournalAutocomplete($reference) {
  $('.reference_form .journal', $reference).autocomplete({
    selectFirst: true,
    source: "/journals",
    minLength: 3
  });
}
