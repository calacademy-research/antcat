# frozen_string_literal: true

require 'rails_helper'

feature "Editing a user", %(
  As a user of AntCat
  I want to edit my password and email
), :skip_ci do
  background do
    this_user_exists email: "quintus@antcat.org", name: "Batiatus", password: "secret"
    i_log_in_as "Batiatus"
  end

  scenario "Changing password" do
    i_go_to 'the main page'
    i_follow "Batiatus", within: 'the desktop menu'
    i_follow "My account"
    i_fill_in "user_password", with: "new password"
    i_fill_in "user_password_confirmation", with: "new password"
    i_fill_in "user_current_password", with: "secret"
    i_press "Save"
    i_should_be_on 'the main page'
    i_should_see "Your account has been updated"

    # Logging in with changed password.
    i_follow "Logout", within: 'the desktop menu'
    i_should_not_see "Batiatus"

    i_follow "Login", within: 'the desktop menu'
    i_fill_in "user_email", with: "quintus@antcat.org"
    i_fill_in "user_password", with: "new password"
    i_press "Login"
    i_should_be_on 'the main page'
    i_should_see "Batiatus"
  end

  scenario "Updating user details" do
    i_go_to 'the main page'
    i_should_see "Batiatus"
    i_should_not_see "Quintus, B."

    i_follow "Batiatus", within: 'the desktop menu'
    i_follow "My account"
    i_fill_in "user_name", with: "Quintus, B."
    i_fill_in "user_current_password", with: "secret"
    i_press "Save"
    i_should_be_on 'the main page'
    i_should_see "Quintus, B."
    i_should_not_see "Batiatus"
  end

  scenario "Updating user preferences" do
    i_go_to 'My account'
    i_should_see_unchecked "#user_settings_editing_helpers_create_combination"

    # Enable setting.
    i_check "user_settings_editing_helpers_create_combination"
    i_press "Save"
    i_should_see "Your account has been updated"

    i_go_to 'My account'
    i_should_see_checked "#user_settings_editing_helpers_create_combination"
    batiatus_editing_helpers_settings_for_create_combination_should_be "true"

    # Disable setting.
    i_uncheck "user_settings_editing_helpers_create_combination"
    i_press "Save"
    i_should_see "Your account has been updated"

    i_go_to 'My account'
    i_should_see_unchecked "#user_settings_editing_helpers_create_combination"
    batiatus_editing_helpers_settings_for_create_combination_should_be "false"
  end
end
