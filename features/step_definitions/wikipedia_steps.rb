Given("there is genus Atta with two species I want to format for Wikipedia") do
  atta = create_genus "Atta"
  extant_species = create_species "Atta cephalotes"
  fossil_species = create_species "Atta mexicana", fossil: true

  # We cannot trust the factories, so set parent here.
  extant_species.genus = atta
  fossil_species.genus = atta
  extant_species.save!
  fossil_species.save!
end

When(/^I append "\/wikipedia" to the URL of that genus' catalog page$/) do
  atta = Taxon.find_by name_cache: "Atta"
  visit "catalog/#{atta.id}/wikipedia"
end
