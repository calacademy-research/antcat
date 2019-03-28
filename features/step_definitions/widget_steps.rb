# Reference selector.
# HACK
Given("the reference selector returns {int} results per page") do |items_per_page|
  allow_any_instance_of(Autocomplete::AutocompleteReferences).
    to receive(:default_search_options).
    and_return(reference_type: :nomissing, items_per_page: items_per_page)
end
