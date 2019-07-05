# TODO: DRY w.r.t `notifications_steps.rb`.

def markdown_textarea
  find ".preview-area textarea"
end

Given("I am on a page with a textarea with markdown preview and autocompletion") do
  step 'I go to the open issues page'
  step 'I follow "New"'
end

When("I fill in {string} with {string} followed by the user id of {string}") do |textarea, text, name|
  user = User.find_by(name: name)
  step %(I fill in "#{textarea}" with "#{text}#{user.id}")
end

When('I fill in the markdown textarea with "@user" followed by my user id') do
  user = User.last
  step %(I fill in "issue_description" with "@user#{user.id}")
end

When('I fill in the markdown textarea with "@taxon" followed by Eciton\'s id') do
  eciton = Taxon.find_by(name_cache: "Eciton")
  step %(I fill in "issue_description" with "%taxon#{eciton.id}")
end

# HACK: Because the below selects the wrong suggestion (which is hidden).
#   `first(".atwho-view-ul li.cur", visible: true).click`
When("I click the suggestion containing {string}") do |text|
  find(".atwho-view-ul li", text: text).click
end

Then("the markdown textarea should contain {string}") do |text|
  expect(markdown_textarea.value).to include text
end

Then("the markdown textarea should contain a markdown link to Archibald's user page") do
  archibald = User.find_by(name: "Archibald")
  expect(markdown_textarea.value).to include "@user#{archibald.id}"
end

# TODO: Less Giovanni.
Then("the markdown textarea should contain a markdown link to the Brother's reference") do
  reference = Reference.find_by(title: "Giovanni's Brother's Favorite Ants")
  expect(markdown_textarea.value).to include "{ref #{reference.id}}"
end

# TODO: Less Giovanni.
When("I fill in {string} with {string} and a markdown link to Giovanni's reference") do |element, string|
  reference = Reference.find_by(title: "Giovanni's Favorite Ants")
  step %(I fill in "#{element}" with "#{string} %reference#{reference.id}}")
end

# TODO: Less Giovanni.
Given("there is a genus {string} with a history item {string} and a markdown link to Giovanni's reference") do |genus, string|
  reference = Reference.find_by(title: "Giovanni's Favorite Ants")
  taxt = "#{string} {ref #{reference.id}}"
  step %(there is a genus "#{genus}" with a history item "#{taxt}")
end

Then("the markdown textarea should contain a markdown link to Eciton") do
  eciton = Taxon.find_by(name_cache: "Eciton")
  expect(markdown_textarea.value).to include "{tax #{eciton.id}}"
end

When("I clear the markdown textarea") do
  step 'I fill in "issue_description" with "%rsomething_to_clear_the_suggestions"'
  markdown_textarea.set ""
end

Then("there should be a textarea with markdown and autocompletion") do
  find "textarea[data-previewable]"
  find "textarea[data-has-mentionables]"
  find "textarea[data-has-linkables]"
end
