Then(/^I should (not )?see the following autocomplete suggestions:$/) do |should_not, table|
  selector = should_not ? :should_not : :should
  table.raw.each do |suggestion|
    page.send selector, have_css(".tt-suggestion", text: suggestion.first)
  end
end

When(/^I click the first autocomplete suggestion$/) do
  first('.tt-suggestion').click
end

Then(/^the search box should contain "(.*?)"$/) do |text|
  expect(page.evaluate_script("$('input#q').val()")).to eq text
end
