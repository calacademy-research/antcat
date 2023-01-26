# frozen_string_literal: true

Given("there is a site notice {string}") do |title|
  there_is_a_site_notice title
end
def there_is_a_site_notice title
  create :site_notice, title: title
end

Given("there is a site notice {string} I haven't read yet") do |title|
  there_is_a_site_notice_i_havent_read_yet title
end
def there_is_a_site_notice_i_havent_read_yet title
  sleep 1 # To please the `unread` gem which uses timestamps.
  create :site_notice, title: title
end

Then("I should see an unread site notice") do
  i_should_see_an_unread_site_notice
end
def i_should_see_an_unread_site_notice
  i_should_see "new notice"
end

Then("I should not see any unread site notices") do
  i_should_not_see_any_unread_site_notices
end
def i_should_not_see_any_unread_site_notices
  i_should_not_see "new notice"
end
