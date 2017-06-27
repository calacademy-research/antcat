Then(/^I should see (\d+) versions?$/) do |expected_count|
  expect(version_items_count).to eq expected_count.to_i
end

def version_items_count
  all("table.versions-test-hook > tbody tr", visible: false).size
end
