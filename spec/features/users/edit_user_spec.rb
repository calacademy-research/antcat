# frozen_string_literal: true

require 'rails_helper'

feature "Editing a user", :skip_ci do
  background do
    batiatus = create :user, email: "quintus@antcat.org", name: "Batiatus", password: "secret"
    login_programmatically batiatus
  end

  scenario "Changing password" do
    i_go_to 'the main page'
    i_follow "Batiatus", within: 'the desktop menu'
    i_follow "My account"
    fill_in "user_password", with: "new password"
    fill_in "user_password_confirmation", with: "new password"
    fill_in "user_current_password", with: "secret"
    click_button "Save"
    i_should_be_on 'the main page'
    i_should_see "Your account has been updated"

    # Logging in with changed password.
    i_follow "Logout", within: 'the desktop menu'
    i_should_not_see "Batiatus"

    i_follow "Login", within: 'the desktop menu'
    fill_in "user_email", with: "quintus@antcat.org"
    fill_in "user_password", with: "new password"
    click_button "Login"
    i_should_be_on 'the main page'
    i_should_see "Batiatus"
  end

  scenario "Updating user details" do
    i_go_to 'the main page'
    i_should_see "Batiatus"
    i_should_not_see "Quintus, B."

    i_follow "Batiatus", within: 'the desktop menu'
    i_follow "My account"
    fill_in "user_name", with: "Quintus, B."
    fill_in "user_current_password", with: "secret"
    click_button "Save"
    i_should_be_on 'the main page'
    i_should_see "Quintus, B."
    i_should_not_see "Batiatus"
  end

  scenario "Updating user preferences" do
    i_go_to 'My account'
    expect(page).to have_unchecked_field("user_settings_editing_helpers_create_combination")

    # Enable setting.
    check "user_settings_editing_helpers_create_combination"
    click_button "Save"
    i_should_see "Your account has been updated"

    i_go_to 'My account'
    expect(page).to have_checked_field("user_settings_editing_helpers_create_combination")
    expect(User.find_by!(name: 'Batiatus').settings(:editing_helpers).create_combination).to eq true

    # Disable setting.
    uncheck "user_settings_editing_helpers_create_combination"
    click_button "Save"
    i_should_see "Your account has been updated"

    i_go_to 'My account'
    expect(page).to have_unchecked_field("user_settings_editing_helpers_create_combination")
    expect(User.find_by!(name: 'Batiatus').settings(:editing_helpers).create_combination).to eq false
  end
end
