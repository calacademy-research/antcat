def login_programmatically user
  login_as user, scope: :user, run_callbacks: false
end

Given("this/these user(s) exists") do |table|
  table.hashes.each { |hash| create :user, hash }
end

When("I log in as {string}") do |name|
  user = User.find_by(name: name)
  login_programmatically user
end

Given('I am logged in') do
  user = create :user
  login_programmatically user
end

Given('I am logged in as a catalog editor') do
  user = create :user, :editor
  login_programmatically user
end

Given('I am logged in as a helper editor') do
  user = create :user, :helper
  login_programmatically user
end

When('I log in as a catalog editor') do
  user = create :user, :editor
  login_programmatically user
end

When('I log in as a catalog editor named {string}') do |name|
  user = create :user, :editor, name: name
  login_programmatically user
end

When('I log in as a superadmin') do
  user = create :user, :editor, :superadmin
  login_programmatically user
end

When('I log in as a superadmin named {string}') do |name|
  user = create :user, :editor, :superadmin, name: name
  login_programmatically user
end

Then("I should see a link to the user page for {string}") do |name|
  user = User.find_by(name: name)

  within first('#content') do
    expect(page).to have_link name, href: user_path(user)
  end
end
