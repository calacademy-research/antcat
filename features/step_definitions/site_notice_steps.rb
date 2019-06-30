Given("there is a site notice {string}") do |title|
  create :site_notice, title: title
end

Given("there is a site notice {string} I haven't read yet") do |title|
  sleep 1 # To please the `unread` gem which uses timestamps.
  create :site_notice, title: title
end

Then("I should see an unread site notice") do
  step 'I should see "new notice"'
end

Then("I should not see any unread site notices") do
  step 'I should not see "new notice"'
end
