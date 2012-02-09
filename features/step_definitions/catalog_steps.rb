# coding: UTF-8
When /I follow "All" in the subfamilies list/ do
  step %{I follow "All" within ".subfamilies"}
end

Then /the browser header should be "(.*?)"/ do |contents|
  words = contents.split ' '
  page.should have_css '#browser .header .taxon_header', :text => words.first
  page.should have_css '#browser .header .taxon_header span', :text => words.second
end

Then /I should not see "(.*?)" by itself in the browser/ do |contents|
  page.should_not have_css('.taxon_header a', :text => contents)
end

Then /"(.*?)" tab should be selected/ do |tab|
  page.should have_css ".catalog_view_selector input[checked=checked][value=#{tab}]"
end

Then /I should be in "(.*?)" mode/ do |mode|
  step %{the "#{mode}" tab should be selected}
end

And /I hide tribes/ do
  step %{I follow "hide"}
end

