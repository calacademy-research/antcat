Given /the following entries exist in the bibliography/ do |table|
  table.hashes.each {|hash| Reference.create! hash}
end

Then 'I should see these entries in this order:' do |entries|
  entries.hashes.each_with_index do |e, i|
    page.should have_css "table.references tr:nth-of-type(#{i + 1}) td", :text => e['entry']
  end
end

Then /I should see "([^"]*)" in italics/ do |italicized_text|
  page.should have_css('span.taxon', :text => italicized_text)  
end

Then /^there should be the HTML "(.*)"$/ do |html|
  body.should =~ /#{html}/
end

Then /I should (not )?see an edit form/ do |should_not|
  selector = should_not ? :should_not : :should
  page.send(selector, have_css('form.edit_reference'))
end
