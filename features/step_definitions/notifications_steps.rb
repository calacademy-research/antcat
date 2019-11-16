Given("I have an(other) unseen notification") do
  Notification.create!(
    reason: :mentioned_in_thing,
    attached: create(:issue),
    user: User.find_by(name: "Archibald"),
    notifier: create(:user)
  )
end

Then("I should see {int} notification(s)") do |expected_count|
  all "table.notifications > tbody tr", count: expected_count.to_i
end

Then("I should see {int} unread notification(s)") do |expected_count|
  all "table.notifications .antcat_icon.unseen", count: expected_count.to_i
end

Given("there is an open issue {string} created by {string}") do |title, name|
  create :issue, title: title, adder: User.find_by(name: name)
end

When(/^I write a new comment <at Batiatus's id> "([^"]*)"$/) do |content|
  batiatus_id = User.find_by(name: "Batiatus").id
  first("#comment_body").set "@user#{batiatus_id} #{content}"
end

When(/^I write a comment reply <at Batiatus's id> "I love you list already!"$/) do
  batiatus_id = User.find_by(name: "Batiatus").id
  first(".reply-form #comment_body").set "@user#{batiatus_id} I love you list already!"
end
