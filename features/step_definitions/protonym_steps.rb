Given("there is a genus protonym {string} with pages and form 'page 9, dealate queen'") do |name_string|
  Feed.without_tracking do
    name = create :genus_name, name: name_string
    citation = create :citation, forms: 'dealate queen', pages: 'page 9'
    create :protonym, name: name, authorship: citation
  end
end

When("I pick {string} from the protonym selector") do |name|
  select2 name, from: 'taxon_protonym_id'
end
