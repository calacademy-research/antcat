# frozen_string_literal: true

require 'rails_helper'

feature "Logging in" do
  scenario "Logging and returning to previous page" do
    create :user, email: "quintus@antcat.org", name: "Batiatus", password: "secret"

    i_go_to 'the references page'
    i_should_not_see "Logout"

    i_follow "Login", within: 'the desktop menu'
    fill_in "user_email", with: "quintus@antcat.org"
    fill_in "user_password", with: "secret"
    click_button "Login"
    i_should_be_on 'the references page'
    i_should_see "Logout"
  end

  scenario "Logging in unsuccessfully" do
    i_go_to 'the main page'
    i_follow "Login", within: 'the desktop menu'
    fill_in "user_email", with: "quintus@antcat.org"
    fill_in "user_password", with: "asd;fljl;jsdfljsdfj"
    click_button "Login"
    i_should_be_on 'the login page'
  end

  scenario "Logging with a locked account" do
    create :user, email: "quintus@antcat.org", name: "Batiatus", password: "secret", locked: true

    i_go_to 'the main page'
    i_follow "Login", within: 'the desktop menu'
    fill_in "user_email", with: "quintus@antcat.org"
    fill_in "user_password", with: "secret"
    click_button "Login"
    i_should_be_on 'the login page'
    i_should_see "Your account has not been activated yet, or it been deactivated"
  end
end
