# frozen_string_literal: true

def there_is_an_open_issue_created_by title, name
  create :issue, title: title, user: User.find_by!(name: name)
end

def i_write_a_new_comment_at_batiatus_id content
  user = User.find_by!(name: "Batiatus")
  first("#comment_body").set "@user#{user.id} #{content}"
end
