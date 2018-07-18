# TODO probably remove all those `Feed.without_tracking` (the feed
# is disabled by default in tests) and create new steps in `feed_steps.rb`.

Given("this/these user(s) exists") do |table|
  table.hashes.each { |hash| User.create! hash }
end

Given('I am not logged in') do
end

def login_programmatically user
  login_as user, scope: :user, run_callbacks: false
  @user = user # Add as instance variable to make it available for other steps.

  # TODO move to individual scenarios. Many scenarios bypassed the main page
  # by directly visiting other paths.
  step 'I go to the main page'
end

When("I log in as {string}") do |name|
  user = User.find_by name: name
  login_programmatically user
end

# TODO change to "I am loged in as an editor" because we want to
# open registration to non-editors in the future.
Given('I am logged in') do
  user = Feed.without_tracking { create :editor }
  login_programmatically user
end

When(/^I log in as a user \(not editor\)$/) do
  user = Feed.without_tracking { create :user }
  login_programmatically user
end

Given("there is a user named {string}") do |name|
  name = "Quintus Batiatus" if name.blank?
  create :editor, name: name
end

# "catalog editor" and "editor" are the same. There used to be -- at least
# in Cucumber tests -- a user role called "bibliography editor" that really
# meant a registered non-editor user. They may have had special privileges in
# the past, or perhaps the feature was never implemented. At any rate, there's
# no such thing at the moment, but we may want to add something similar.
# TODO investigate adding/reinstating a "bibliography editor" user role.
When(/^I log in as a catalog editor(?: named "([^"]+)")?$/) do |name|
  name = "Quintus Batiatus" if name.blank?
  user = User.find_by name: name
  user ||= Feed.without_tracking do
    create :editor, name: name
  end
  login_programmatically user
end

When(/^I log in as a superadmin(?: named "([^"]+)")?$/) do |name|
  name = "Quintus Batiatus" if name.blank?
  user = Feed.without_tracking do
    create :user, can_edit: true, is_superadmin: true, name: name
  end
  login_programmatically user
end

When("I log out and log in again") do
  step 'I log out'
  login_programmatically @user
end

When("I log out") do
  step 'I follow the first "Logout"'
  step %(I should see "You're logged out")
end

When("I fill in the email field with my email address") do
  user = User.find_by(name: 'Brian Fisher') # TODO something. Harcoded.
  step %(I fill in "user_email" with "#{user.email}")
end

Then("there should be a mailto link to the email of {string}") do |name|
  email = User.find_by(name: name).email
  within first('#content') do
    find :css, "a[href='mailto:#{email}']"
  end
end

Then("I should see a link to the user page for {string}") do |name|
  user = User.find_by name: name

  within first('#content') do
    expect(page).to have_link name, href: user_path(user)
  end
end
