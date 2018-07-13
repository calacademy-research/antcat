Then(/^I should (not )?see the following autocomplete suggestions:$/) do |should_not, table|
  table.raw.each do |suggestion|
    if should_not
      expect(page).to have_no_css ".tt-suggestion", text: suggestion.first
    else
      expect(page).to have_css ".tt-suggestion", text: suggestion.first
    end
  end
end

When("I click the first autocomplete suggestion") do
  first('.tt-suggestion').click
end

Then("the search box should contain {string}") do |text|
  expect(page.evaluate_script("$('input#q').val()")).to eq text
end

When("I start filling in {string} with {string}") do |field, value|
  wait_for_jquery
  find(field).set value
end
