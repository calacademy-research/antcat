Then /^I (#{SHOULD_OR_SHOULD_NOT}) see the following autocomplete suggestions:$/ do |should_selector, table|
  table.raw.each do |suggestion|
    page.send(should_selector.to_sym, have_css(".tt-suggestion", text: suggestion.first))
  end
end

Then /^I click the first autocomplete suggestion$/ do
  first('.tt-suggestion').click
end

Then /^the search box should contain "(.*?)"$/ do |text|
  expect(page.evaluate_script("$('input#q').val()")).to eq text
end
