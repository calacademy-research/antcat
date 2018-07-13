Given("the following names exist for an(other) author") do |table|
  author = create :author
  table.raw.each { |row| author.names.create! name: row.first }
end

When(/I fill in "([^"]+)" in (the (?:(?:first|last|another) )?author panel) with "(.*?)"/) do |field, parent, search_term|
  with_scope parent do
    step %{I fill in "#{field}" with "#{search_term}"}
  end
end

When("I search for {string} in the author panel") do |term|
  steps %{
    And I fill in "Choose author" in the author panel with "#{term}"
    And I press "Go" in the author panel
  }
end

When("I search for {string} in another author panel") do |term|
  steps %{
    And I fill in "Choose another author" in the last author panel with "#{term}"
    And I press "Go" in the last author panel
  }
end

When("I close the first author panel") do
  step %{I follow "close" in the first author panel}
end

When("I merge the authors") do
  steps %{
    And I will confirm on the next step
    And I press "Merge these authors"
  }
end

Then("I should not be able to merge the authors") do
  step %{I should not see "Click this button"}
end
