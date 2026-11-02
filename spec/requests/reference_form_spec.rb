# frozen_string_literal: true

require 'rails_helper'

describe "Reference form" do
  before do
    sign_in create(:user, :helper)
  end

  describe "authors suffix" do
    before do
      create :any_reference, author_names_suffix: '(ed.)'
      create :any_reference, author_names_suffix: nil
    end

    it "is blank for a new reference, with the existing suffixes to choose from" do
      get new_reference_path

      options = Nokogiri::HTML(response.body).css('#reference_author_names_suffix option')
      expect(options.map { it['value'] }).to eq ['', '(ed.)']
      expect(options.select { it['selected'] }).to eq []
    end
  end
end
