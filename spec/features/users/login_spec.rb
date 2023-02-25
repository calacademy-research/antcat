# frozen_string_literal: true

require 'rails_helper'

feature "Logging in", as: :visitor do
  scenario "Logging and returning to previous page" do
    create :user, email: "quintus@antcat.org", password: "secret"

    visit references_path
    i_should_not_see "Logout"

    i_follow "Login", within: 'the desktop menu'
    fill_in "user_email", with: "quintus@antcat.org"
    fill_in "user_password", with: "secret"
    click_button "Login"
    i_should_be_on references_path
    i_should_see "Logout"
  end

  scenario "Logging in unsuccessfully" do
    visit root_path
    i_follow "Login", within: 'the desktop menu'
    fill_in "user_email", with: "no-account@antcat.org"
    fill_in "user_password", with: "asd;fljl;jsdfljsdfj"
    click_button "Login"
    i_should_be_on new_user_session_path
  end

  scenario "Logging with a locked account" do
    create :user, email: "quintus@antcat.org", password: "secret", locked: true

    visit root_path
    i_follow "Login", within: 'the desktop menu'
    fill_in "user_email", with: "quintus@antcat.org"
    fill_in "user_password", with: "secret"
    click_button "Login"
    i_should_be_on new_user_session_path
    i_should_see "Your account has not been activated yet, or it been deactivated"
  end
end
