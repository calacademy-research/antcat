# frozen_string_literal: true

Given("there is a history item {string}") do |taxt|
  create :taxon_history_item, taxt: taxt
end

Given("there is a subfamily {string} with a history item {string}") do |name, taxt|
  taxon = create :subfamily, name_string: name
  create :taxon_history_item, taxt: taxt, taxon: taxon
end

Given("there is a subfamily {string} with a history item {string} and a markdown link to {string}") do |name, content, key_with_year|
  reference = ReferenceStepsHelpers.find_reference_by_key(key_with_year)
  taxt = "#{content} {ref #{reference.id}}"
  step %(there is a subfamily "#{name}" with a history item "#{taxt}")
end
