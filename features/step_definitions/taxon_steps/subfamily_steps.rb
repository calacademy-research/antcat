Given("there is a subfamily {string} with a reference section {string}") do |name, references|
  taxon = create :subfamily, name_string: name
  taxon.reference_sections.create! references_taxt: references
end

Given("there is a subfamily {string}") do |name|
  @subfamily = create :subfamily, name_string: name
end

Given("there is an invalid subfamily Invalidinae") do
  create :subfamily, :synonym, name_string: "Invalidinae", current_valid_taxon: create(:family)
end
