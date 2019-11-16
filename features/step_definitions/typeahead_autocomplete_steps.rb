Then(/^I should (not )?see the following autocomplete suggestions:$/) do |should_not, table|
  table.raw.each do |suggestion|
    if should_not
      expect(page).to have_no_css ".tt-suggestion", text: suggestion.first, normalize_ws: true
    else
      expect(page).to have_css ".tt-suggestion", text: suggestion.first, normalize_ws: true
    end
  end
end

When("I click the first autocomplete suggestion") do
  first('.tt-suggestion').click
end

Then("the search box should contain {string}") do |content|
  expect(page.evaluate_script("$('input#reference_q').val()")).to eq content
end

When("I start filling in {string} with {string}") do |css_selector, value|
  wait_for_jquery
  find(css_selector).set value
end
