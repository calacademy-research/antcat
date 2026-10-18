# frozen_string_literal: true

require 'rails_helper'

describe "Requesting a password reset" do
  before do
    ActionMailer::Base.deliveries.clear
    create :user, email: 'existing@example.com'
  end

  def request_reset email
    post user_password_path, params: { user: { email: email } }
    [response.status, response.location, flash[:notice], flash[:alert]]
  end

  it "responds the same whether or not the email has an account (Devise paranoid mode)" do
    expect(Devise.paranoid).to eq true

    unknown = request_reset 'nobody@example.com'
    existing = request_reset 'existing@example.com'

    expect(unknown).to eq existing
    expect(ActionMailer::Base.deliveries.map(&:to)).to eq [['existing@example.com']]
  end
end
