# frozen_string_literal: true

def there_is_a_site_notice title
  create :site_notice, title: title
end

def there_is_a_site_notice_i_havent_read_yet title
  sleep 1 # To please the `unread` gem which uses timestamps.
  create :site_notice, title: title
end

def i_should_see_an_unread_site_notice
  i_should_see "new notice"
end

def i_should_not_see_any_unread_site_notices
  i_should_not_see "new notice"
end
