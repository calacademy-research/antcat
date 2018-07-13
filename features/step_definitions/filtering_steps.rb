Then("I should see {int} version(s)") do |expected_count|
  expect(version_items_count).to eq expected_count.to_i
end

def version_items_count
  all("table.versions-test-hook > tbody tr", visible: false).size
end
