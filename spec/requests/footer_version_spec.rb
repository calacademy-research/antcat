# frozen_string_literal: true

require 'rails_helper'

describe "Footer version" do
  let(:sha) { "5166c5a2#{'0' * 32}" }

  it "shows the short commit next to the version, linked to GitHub" do
    stub_const("AntCat::COMMIT", sha)
    get page_path('about')

    expect(response.body).to include "Version #{AntCat::VERSION}"
    expect(response.body).to include %(href="https://github.com/calacademy-research/antcat/commit/#{sha}")
    expect(response.body).to include ">5166c5a</a>"
  end

  it "shows only the version when the commit is not known" do
    stub_const("AntCat::COMMIT", nil)
    get page_path('about')

    expect(response.body).to include "Version #{AntCat::VERSION}"
    expect(response.body).not_to include "/antcat/commit/"
  end
end
