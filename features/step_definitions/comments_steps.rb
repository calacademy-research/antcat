When("I write a new comment {string}") do |text|
  first("#comment_body").set text
end

When("I write a reply with the text {string}") do |text|
  all("#comment_body").last.set text
end

Given('Batiatus has commented "Cool" on an issue with the title "Typos"') do
  issue = create :issue, title: "Typos"
  batiatus = User.find_by(name: "Batiatus")
  Comment.build_comment(issue, batiatus, body: "Cool").save!
end

Then("I should see a comments section") do
  find ".comments-container"
end

# HACK: x 2:
#   * We're only checking that the URL contains the string "#comment-" (anchor tag).
#   * We're getting the URL via JavaScript because I could not get Capybara to do it.
Then("I should see my comment highlighted in the comments section") do
  url_via_javascript = page.evaluate_script "window.location.href"
  expect(url_via_javascript).to include "#comment-"
end

When("I hover the comment") do
  find(".highlight-comment-anchor").hover
end
