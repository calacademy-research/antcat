When(/^I write a new comment "([^"]*)"$/) do |text|
  first("#comment_body").set text
end

When(/^I write a reply with the text "([^"]*)"$/) do |text|
  all("#comment_body").last.set text
end

Given('Batiatus has commented "Cool" on a task with the title "Typos"') do
  task = create :task, title: "Typos"
  batiatus = User.find_by(name: "Batiatus")
  Comment.build_comment(task, batiatus, "Cool").save!
end
