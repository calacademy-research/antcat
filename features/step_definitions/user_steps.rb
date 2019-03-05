# TODO probably remove all those `Feed.without_tracking` (the feed
# is disabled by default in tests) and create new steps in `feed_steps.rb`.

Given("this/these user(s) exists") do |table|
  table.hashes.each { |hash| User.create! hash }
end

def login_programmatically user
  login_as user, scope: :user, run_callbacks: false
  @current_cucumber_user = user # Add as instance variable to make it available for other steps.
end

When("I log in as {string}") do |name|
  user = User.find_by name: name
  login_programmatically user
end

Given('I am logged in') do
  user = Feed.without_tracking { create :user }
  login_programmatically user
end

Given('I am logged in as a catalog editor') do
  user = Feed.without_tracking { create :user, :editor }
  login_programmatically user
end

Given('I am logged in as a helper editor') do
  user = Feed.without_tracking { create :user, :helper }
  login_programmatically user
end

Given("there is a user named {string}") do |name|
  create :user, :editor, name: name
end

When(/^I log in as a catalog editor(?: named "([^"]+)")?$/) do |name|
  name = "Quintus Batiatus" if name.blank?
  user = User.find_by name: name
  user ||= Feed.without_tracking do
    create :user, :editor, name: name
  end
  login_programmatically user
end

When(/^I log in as a superadmin(?: named "([^"]+)")?$/) do |name|
  name = "Quintus Batiatus" if name.blank?
  user = Feed.without_tracking do
    create :user, :editor, :superadmin, name: name
  end
  login_programmatically user
end

When("I log out and log in again") do
  step 'I log out'
  login_programmatically @current_cucumber_user
end

When("I log out") do
  step 'I follow the first "Logout"'
  step 'I should see "Login"'
end

When("I fill in the email field with my email address") do
  user = User.find_by(name: 'Mark Wilden') # TODO something. Harcoded.
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
