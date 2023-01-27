# frozen_string_literal: true

def there_is_a_site_notice_i_havent_read_yet title
  sleep 1 # To please the `unread` gem which uses timestamps.
  create :site_notice, title: title
end
