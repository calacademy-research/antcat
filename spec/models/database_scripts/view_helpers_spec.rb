# frozen_string_literal: true

require 'rails_helper'

describe DatabaseScripts::ViewHelpers do
  let(:script) { DatabaseScripts::DatabaseTestScript.new }

  describe "#as_taxon_table" do
    let!(:taxon) { create :genus, name_string: "Lasius" }

    it "doesn't require a description" do
      allow(script).to receive(:results).and_return [taxon]
      expect(script.as_taxon_table).to match "<table"
      expect(script.as_taxon_table).to match "<th>Taxon"
      expect(script.as_taxon_table).to match "<i>Lasius</i>"
    end
  end

  describe "#as_reference_list" do
    let!(:refernece) { create :any_reference, title: "Pizza Ants" }

    it "doesn't require a description" do
      allow(script).to receive(:results).and_return [refernece]
      expect(script.as_reference_list).to match "<ul>\n<li>"
      expect(script.as_reference_list).to match "Pizza Ants"
    end
  end
end
