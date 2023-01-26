# frozen_string_literal: true

def login_programmatically user
  login_as user, scope: :user, run_callbacks: false
end

Given("this/these user(s) exists") do |table|
  table.hashes.each { |hash| create :user, hash }
end
def this_user_exists **hsh
  create :user, hsh
end

When("I log in as {string}") do |name|
  i_log_in_as name
end
def i_log_in_as name
  user = User.find_by!(name: name)
  login_programmatically user
end

Given('I am logged in') do
  i_am_logged_in
end
def i_am_logged_in
  user = create :user
  login_programmatically user
end

When('I log in as a user named {string}') do |name|
  i_log_in_as_a_user_named name
end
def i_log_in_as_a_user_named name
  user = create :user, name: name
  login_programmatically user
end

Given('I log in as a helper editor') do
  i_log_in_as_a_helper_editor
end
def i_log_in_as_a_helper_editor
  user = create :user, :helper
  login_programmatically user
end

When('I log in as a catalog editor') do
  i_log_in_as_a_catalog_editor
end
def i_log_in_as_a_catalog_editor
  user = create :user, :editor
  login_programmatically user
end

When('I log in as a catalog editor named {string}') do |name|
  i_log_in_as_a_catalog_editor_named name
end
def i_log_in_as_a_catalog_editor_named name
  user = create :user, :editor, name: name
  login_programmatically user
end

When('I log in as a superadmin') do
  i_log_in_as_a_superadmin
end
def i_log_in_as_a_superadmin
  user = create :user, :editor, :superadmin
  login_programmatically user
end

When('I log in as a superadmin named {string}') do |name|
  i_log_in_as_a_superadmin_named name
end
def i_log_in_as_a_superadmin_named name
  user = create :user, :editor, :superadmin, name: name
  login_programmatically user
end

When('I log in as a developer') do
  i_log_in_as_a_developer
end
def i_log_in_as_a_developer
  user = create :user, :editor, :developer
  login_programmatically user
end

Then("Batiatus' editing_helpers settings for create_combination should be {string} [Boolean]") do |value|
  batiatus_editing_helpers_settings_for_create_combination_should_be value
end
def batiatus_editing_helpers_settings_for_create_combination_should_be value
  user = User.find_by!(name: 'Batiatus')
  boolean_value = { 'true' => true, 'false' => false }.fetch(value)
  expect(user.settings(:editing_helpers).create_combination).to eq boolean_value
end
