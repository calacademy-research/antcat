# frozen_string_literal: true

require 'rails_helper'

describe "Signing in with a wrong password" do
  before { create :user, email: 'existing@example.com' }

  def sign_in_with email
    post user_session_path, params: { user: { email: email, password: 'wrong-password-123' } }
    [response.status, flash[:alert]]
  end

  it "responds the same whether or not the email has an account" do
    expect(sign_in_with('nobody@example.com')).to eq sign_in_with('existing@example.com')
  end
end
