require 'spec_helper'

describe Taxa::InheritAttributesForNewCombination do
  describe "#call" do
    let(:new_comb_parent) { build_stubbed :genus }
    let(:new_comb) do
      taxon = Species.new
      taxon.build_name
      taxon.build_type_name
      taxon.build_protonym
      taxon.protonym.build_name
      taxon.protonym.build_authorship
      taxon
    end
    let(:old_comb) do
      stub_request(:any, "http://antcat.org/1.pdf").to_return body: "not 404"
      create :species, biogeographic_region: "Neotropic"
    end

    it "copies relevant fields from `old_comb`" do
      # We want to copy these.
      attributes = [:protonym, :biogeographic_region]

      # Confirm factory.
      attributes.each { |attribute| expect(old_comb.send(attribute)).to be_present }

      # Act and test
      described_class[new_comb, old_comb, new_comb_parent]

      attributes.each do |attribute|
        expect(old_comb.send(attribute)).to eq new_comb.send(attribute)
      end
    end

    it "sets the name" do
      expect(new_comb.name.name).to be_blank
      described_class[new_comb, old_comb, new_comb_parent]
      expect(new_comb.name.name).to be_present
    end

    it "raises on invalid rank combinations" do
      new_comb = create :subspecies
      old_comb = create :species
      irrelevant_parent = create :subfamily

      expect do
        described_class[new_comb, old_comb, irrelevant_parent]
      end.to raise_error "rank mismatch"
    end
  end
end
