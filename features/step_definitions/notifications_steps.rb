# frozen_string_literal: true

Given("I have an(other) unseen notification") do
  i_have_an_unseen_notification
end
def i_have_an_unseen_notification
  create :notification, user: User.find_by!(name: "Archibald")
end

def i_have_another_unseen_notification
  i_have_an_unseen_notification
end

Then("I should see {int} notification(s)") do |expected_count|
  i_should_see_number_of_notification expected_count
end
def i_should_see_number_of_notification expected_count
  all "table.notifications > tbody tr", count: expected_count.to_i
end

Then("I should see {int} unread notification(s)") do |expected_count|
  i_should_see_number_of_unread_notifications expected_count
end
def i_should_see_number_of_unread_notifications expected_count
  all "table.notifications .antcat_icon.unseen", count: expected_count.to_i
end

Given("there is an open issue {string} created by {string}") do |title, name|
  there_is_an_open_issue_created_by title, name
end
def there_is_an_open_issue_created_by title, name
  create :issue, title: title, user: User.find_by!(name: name)
end

When(/^I write a new comment <at Batiatus's id> "([^"]*)"$/) do |content|
  i_write_a_new_comment_at_batiatus_id content
end
def i_write_a_new_comment_at_batiatus_id content
  user = User.find_by!(name: "Batiatus")
  first("#comment_body").set "@user#{user.id} #{content}"
end
