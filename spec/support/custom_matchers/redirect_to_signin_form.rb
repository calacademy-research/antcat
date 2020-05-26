# frozen_string_literal: true

require 'rspec/expectations'

RSpec::Matchers.define :redirect_to_signin_form do |_expected|
  match do |_actual|
    expect(response).to have_http_status :found
    expect(response.body).
      to eq '<html><body>You are being <a href="http://test.host/my/users/sign_in">redirected</a>.</body></html>'
  end
end
