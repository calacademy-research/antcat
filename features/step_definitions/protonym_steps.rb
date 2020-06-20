# frozen_string_literal: true

Given("there is a genus protonym {string}") do |name_string|
  name = create :genus_name, name: name_string
  create :protonym, name: name
end

Given("there is a genus protonym {string} with pages and form 'page 9, dealate queen'") do |name_string|
  name = create :genus_name, name: name_string
  citation = create :citation, pages: 'page 9'
  create :protonym, name: name, authorship: citation, forms: 'dealate queen'
end

When("I pick {string} from the protonym selector") do |name|
  select2 name, from: 'taxon_protonym_id'
end
