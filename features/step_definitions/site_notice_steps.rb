Given("there is a( new) site notice I haven't read yet") do
  sleep 1 # To please the `unread` gem which uses timestamps.
  create :site_notice, title: "A Site Notice", message: "Cash is King, that's the message."
  expect(SiteNotice.unread_by(@current_cucumber_user)).to be_present
end

Then("I should see an unread site notice") do
  step 'I should see "new notice"'
end

Then("I should not see any unread site notices") do
  step 'I should not see "new notice"'
end
