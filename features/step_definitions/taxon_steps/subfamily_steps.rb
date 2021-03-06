# frozen_string_literal: true

Given("there is a subfamily {string}") do |name|
  create :subfamily, name_string: name
end

Given("there is an invalid subfamily Invalidinae") do
  create :subfamily, :synonym, name_string: "Invalidinae", current_taxon: create(:family)
end
