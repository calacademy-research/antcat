require "spec_helper"

describe DatabaseScripts::DuplicatedReferenceSections do
  describe "#results" do
    let!(:taxon) { create :family }
    let!(:duplicate_reference_section) do
      taxon.reference_sections.create references_taxt: 'Taxt', position: 2
    end

    before do
      taxon.reference_sections.create references_taxt: 'Taxt', position: 1
      taxon.reference_sections.create references_taxt: 'Not taxt', position: 3
    end

    it "returns one of the duplicate reference sections" do
      expect(taxon.reference_sections.count).to eq 3
      expect(described_class.new.results).to eq [duplicate_reference_section]
    end
  end
end
