# frozen_string_literal: true

def i_have_an_unseen_notification
  create :notification, user: User.find_by!(name: "Archibald")
end

def i_have_another_unseen_notification
  i_have_an_unseen_notification
end

def i_should_see_number_of_notification expected_count
  all "table.notifications > tbody tr", count: expected_count.to_i
end

def i_should_see_number_of_unread_notifications expected_count
  all "table.notifications .antcat_icon.unseen", count: expected_count.to_i
end

def there_is_an_open_issue_created_by title, name
  create :issue, title: title, user: User.find_by!(name: name)
end

def i_write_a_new_comment_at_batiatus_id content
  user = User.find_by!(name: "Batiatus")
  first("#comment_body").set "@user#{user.id} #{content}"
end
