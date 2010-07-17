Given /the following entries exist in the bibliography/ do |table|
  table.hashes.each do |hash|
    Reference.create! hash
  end
end

Then /I should see "([^"]*)" in italics/ do |italicized_text|
  page.should have_css('span.taxon', :text => italicized_text)  
end
