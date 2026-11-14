# frozen_string_literal: true

require 'rails_helper'

# The New user form was removed (2026-11-13): accounts are made by signing up. Without the route, /users/new is read
# as users#show with the id "new"; it must be "not found", never a server error.
describe "The removed New user form" do
  it "answers 404 for /users/new" do
    get "/users/new"
    expect(response).to have_http_status :not_found
  end

  it "answers 404 for /users/new when a superadmin is signed in" do
    sign_in create(:user, :superadmin)
    get "/users/new"
    expect(response).to have_http_status :not_found
  end
end
