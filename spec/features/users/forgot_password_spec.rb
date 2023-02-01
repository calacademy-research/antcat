# frozen_string_literal: true

require 'rails_helper'

feature "Forgot password" do
  background do
    these_settings 'email: { enabled: true }'
  end

  scenario "Visiting the forgot password page" do
    i_go_to 'the main page'
    i_follow "Login", within: 'the desktop menu'
    i_follow "Forgot password"
    i_should_see "Send me reset password instructions"
  end
end
