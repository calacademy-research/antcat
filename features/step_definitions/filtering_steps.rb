Then("I should see {int} version(s)") do |count|
  all "table tbody tr", count: count
end
