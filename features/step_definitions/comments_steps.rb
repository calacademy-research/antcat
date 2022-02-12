# frozen_string_literal: true

When("I write a new comment {string}") do |body|
  first("#comment_body").set body
end

Given('Batiatus has commented "Cool" on an issue with the title "Typos"') do
  issue = create :issue, title: "Typos"
  user = User.find_by!(name: "Batiatus")
  Comment.build_comment(issue, user, body: "Cool").save!
end

Then("I should see a comments section") do
  find ".comments-section"
end
