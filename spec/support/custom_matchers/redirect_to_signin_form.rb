# frozen_string_literal: true

require 'rspec/expectations'

RSpec::Matchers.define :redirect_to_signin_form do |_expected|
  match do |_actual|
    expect(response).to have_http_status :found
    expect(response.headers['location']).to eq "http://test.host/users/sign_in"
    expect(response.body).to eq ""
  end
end
