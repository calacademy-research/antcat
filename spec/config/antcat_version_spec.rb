# frozen_string_literal: true

require 'rails_helper'

describe "AntCat::VERSION" do
  it "is the release number from the VERSION file" do
    expect(AntCat::VERSION).to eq Rails.root.join("VERSION").read.strip
    expect(AntCat::VERSION).to match(/\A\d+\.\d+\.\d+\z/)
  end
end
