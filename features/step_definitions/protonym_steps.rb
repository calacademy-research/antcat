Given("there is a genus protonym {string} with pages and form 'page 9, dealate queen'") do |name_string|
  name = create :genus_name, name: name_string
  citation = create :citation, forms: 'dealate queen', pages: 'page 9'
  create :protonym, name: name, authorship: citation
end
