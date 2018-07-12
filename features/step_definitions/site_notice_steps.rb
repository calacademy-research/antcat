Given("there is a( new) site notice I haven't read yet") do
  sleep 1 # To please the `unread` gem which uses timestamps.
  create :site_notice, title: "A Site Notice", message: "Cash is King, that's the message."
  expect(SiteNotice.unread_by(@user)).to be_present
end

Then("I should see an unread site notice") do
  should_see_unread
end

Then("I should not see any unread site notices") do
  should_not_see_unread
end

Then("I should see {int} unread site notice(s)") do |expected_count|
  expect(site_notices_count).to eq expected_count.to_i
  if expected_count.to_i.zero? then should_not_see_unread else should_see_unread end
end

def site_notices_count
  all(".site-notice-test-hook").size
end

def should_see_unread
  step 'I should see "Unread site notices"'
end

def should_not_see_unread
  step 'I should not see "Unread site notices"'
end
