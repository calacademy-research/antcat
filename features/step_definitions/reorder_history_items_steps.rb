Given('there is a genus Orderia with the history items "AAA", "BBB" and "CCC"') do
  taxon = create_genus "Orderia"
  taxon.history_items.create! taxt: "AAA"
  taxon.history_items.create! taxt: "BBB"
  taxon.history_items.create! taxt: "CCC"
end

When("I drag the AAA history item a bit") do
  aaa = find ".history-item", text: "AAA"
  ccc = find ".history-item", text: "CCC"
  aaa.drag_to ccc
end

When("I click on Reorder in the history section") do
  find("#start-reordering-history-items").click
end

When("I click on Cancel in the history section") do
  find("#cancel-history-item-reordering").click
end

When("I click on Save new order in the history section") do
  find("#save-reordered-history-items").click
end
