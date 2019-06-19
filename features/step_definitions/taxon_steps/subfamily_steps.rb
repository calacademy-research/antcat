Given("there is a subfamily {string} with a reference section {string}") do |name, references|
  subfamily_name = create :subfamily_name, name: name
  taxon = create :subfamily, name: subfamily_name
  taxon.reference_sections.create! references_taxt: references
end

Given("there is a subfamily {string}") do |name|
  subfamily_name = create :subfamily_name, name: name
  @subfamily = create :subfamily, name: subfamily_name
end

Given("there is an invalid subfamily Invalidinae") do
  name = create :subfamily_name, name: "Invalidinae"
  create :subfamily, :synonym, name: name, current_valid_taxon: create(:family)
end
