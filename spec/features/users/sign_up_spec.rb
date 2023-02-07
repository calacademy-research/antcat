# frozen_string_literal: true

require 'rails_helper'

feature "Signing up", as: :visitor do
  scenario "Sign up (with feed)" do
    i_go_to 'the main page'
    i_follow "Sign up", within: 'the desktop menu'
    fill_in "user_email", with: "pizza@example.com"
    fill_in "user_name", with: "Quintus Batiatus"
    fill_in "user_password", with: "secret123"
    fill_in "user_password_confirmation", with: "secret123"
    click_button "Sign Up"
    i_should_be_on 'the main page'
    i_should_see "Welcome! You have signed up successfully."

    there_should_be_an_activity "Quintus Batiatus registered an account, welcome to antcat.org!"
  end
end
