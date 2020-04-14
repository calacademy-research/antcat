# frozen_string_literal: true

require 'rails_helper'

describe DatabaseScripts::RenderHelpers do
  let(:database_script) { DatabaseScripts::DatabaseTestScript.new }

  before do
    database_script.extend described_class
  end

  describe "#as_taxon_table" do
    let!(:taxon) { create :genus, name_string: "Lasius" }

    it "doesn't require a description" do
      allow(database_script).to receive(:results).and_return [taxon]

      expect(database_script.as_taxon_table).to match "<table"
      expect(database_script.as_taxon_table).to match "<th>Taxon"
      expect(database_script.as_taxon_table).to match "<i>Lasius</i>"
    end
  end

  describe "#as_reference_table" do
    let!(:reference) { create :any_reference, title: "Pizza Ants" }

    it "doesn't require a description" do
      allow(database_script).to receive(:results).and_return [reference]

      expect(database_script.as_reference_table).to match "<ul>\n<li>"
      expect(database_script.as_reference_table).to match "Pizza Ants"
    end
  end
end
