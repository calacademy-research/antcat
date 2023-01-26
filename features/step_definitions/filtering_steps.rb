# frozen_string_literal: true

Then("I should see {int} version(s)") do |count|
  i_should_see_number_of_versions count
end
def i_should_see_number_of_versions count
  all "table tbody tr", count: count
end
