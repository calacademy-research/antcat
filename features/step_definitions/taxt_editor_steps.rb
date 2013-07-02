# coding: UTF-8

Then /^the taxt editor should contain the tag for "(.*?)"$/ do |key|
  page.find('#name').value.should == Taxt.encode_reference(DefaultReference.get)
end
