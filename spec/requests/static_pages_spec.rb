# frozen_string_literal: true

require 'rails_helper'

# GET /*id (anyone): the static pages of app/views/pages (high_voltage gem, the last route; docs/catalog/routes.tsv).
describe "Static pages" do
  it "opens a page by its name" do
    get "/about"
    expect(response).to have_http_status :ok
    expect(response.body).to include "Version #{AntCat::VERSION}"
  end

  it "answers 404 for a page that does not exist" do
    get "/no_such_page_here"
    expect(response).to have_http_status :not_found
  end
end
