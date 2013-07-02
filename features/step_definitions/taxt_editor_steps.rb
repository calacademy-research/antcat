# coding: UTF-8

Then /^the taxt editor should contain the editable taxt for "(.*?)"$/ do |key|
  reference = find_reference_by_key key
  page.find('#name').value.strip.should == Taxt.to_editable_reference(reference)
end
