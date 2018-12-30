Then("I should see {int} version(s)") do |count|
  all "table.versions-test-hook tr", count: count
end
