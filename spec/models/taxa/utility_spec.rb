require 'spec_helper'

describe Taxa::Utility do
  describe ".inherit_attributes_for_new_combination" do
    let(:new_comb_parent) { create_genus "Atta" }
    let(:new_comb) { build_new_taxon :species }
    let(:old_comb) do
      stub_request(:any, "http://antcat.org/1.pdf").to_return body: "not 404"
      create :species, verbatim_type_locality: "Bolivia",
        biogeographic_region: "Neotropic", type_specimen_repository: "I keep it in a box",
        type_specimen_code: "999", type_specimen_url: "http://antcat.org/1.pdf"
    end

    it "copies relevant fields from `old_comb`" do
      # We want to copy these.
      attributes = [:protonym, :verbatim_type_locality, :biogeographic_region,
        :type_specimen_repository, :type_specimen_code, :type_specimen_url]

      # Confirm factory.
      attributes.each { |attribute| expect(old_comb.send attribute).to be_present }

      # Act and test
      Taxa::Utility.inherit_attributes_for_new_combination new_comb, old_comb, new_comb_parent

      attributes.each do |attribute|
        expect(old_comb.send attribute).to eq new_comb.send(attribute)
      end
    end

    it "doesn't copy irrelevant fields`" do
      # TODO
    end

    it "sets name" do
      expect(new_comb.name.name).to be_blank
      Taxa::Utility.inherit_attributes_for_new_combination new_comb, old_comb, new_comb_parent
      expect(new_comb.name.name).to be_present
    end

    it "raises on invalid rank combinations" do
      new_comb = create_species
      old_comb = create_species
      invalid_new_comb_parent = create_subfamily

      expect do
        Taxa::Utility.inherit_attributes_for_new_combination new_comb,
          old_comb, invalid_new_comb_parent
      end.to raise_error
    end
  end

  describe ".name_for_new_comb" do
    let(:genus) { create_genus "Atta" }
    let(:species) { create_species "Lasius cactusia" }
    let(:subspecies) { create_subspecies "Formica luigi peligrosa" }

    context "when `new_comb_parent` is a species" do
      let(:new_comb_parent) { species }
      let(:old_comb) { subspecies }

      it "returns a correctly formatted `SubspeciesName`" do
        new_comb_name = Taxa::Utility.name_for_new_comb old_comb, new_comb_parent

        expect(new_comb_name).to be_a SubspeciesName
        expect(new_comb_name.name).to eq "Lasius cactusia peligrosa"
      end
    end

    context "when `new_comb_parent` is a genus" do
      let(:new_comb_parent) { genus }
      let(:old_comb) { species }

      it "returns a correctly formatted `SpeciesName`" do
        new_comb_name = Taxa::Utility.name_for_new_comb old_comb, new_comb_parent

        expect(new_comb_name).to be_a SpeciesName
        expect(new_comb_name.name).to eq "Atta cactusia"
      end
    end
  end

  describe ".attributes_for_new_usage" do
    # TODO
  end
end
