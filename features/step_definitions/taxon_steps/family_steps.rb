Given("the Formicidae family exists") do
  create :family, name: create(:family_name, name: "Formicidae")
end

Given("Formicidae has a history item {string}") do |string|
  Family.first.history_items << create(:taxon_history_item, taxt: string)
end
