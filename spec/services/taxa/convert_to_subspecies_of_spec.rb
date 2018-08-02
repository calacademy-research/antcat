require 'spec_helper'

describe Taxa::ConvertToSubspeciesOf do
  describe "#call" do
    let(:genus) { create_genus 'Atta' }

    it "turns the record into a Subspecies" do
      taxon = create_species 'Atta minor', genus: genus
      taxon.protonym.name.name = 'Atta (Myrma) minor'
      taxon.protonym.name.save!
      new_species = create_species 'Atta major', genus: genus

      described_class[taxon, new_species]

      taxon = Subspecies.find taxon.id
      expect(taxon.name.name).to eq 'Atta major minor'
      expect(taxon.name.epithets).to eq 'major minor'
      expect(taxon).to be_kind_of Subspecies
      expect(taxon.name).to be_kind_of SubspeciesName
      expect(taxon.name_cache).to eq 'Atta major minor'
    end

    it "sets the species, genus and subfamily" do
      taxon = create_species 'Atta minor', genus: genus
      new_species = create_species 'Atta major', genus: genus

      described_class[taxon, new_species]

      taxon = Subspecies.find taxon.id
      expect(taxon.species).to eq new_species
      expect(taxon.genus).to eq new_species.genus
      expect(taxon.subfamily).to eq new_species.subfamily
    end

    context "when the new subspecies exists" do
      let(:taxon) { create_species 'Camponotus dallatorrei', genus: genus }
      let(:new_species) { create_species 'Camponotus alii', genus: genus }

      before { create_subspecies 'Atta alii dallatorrei', genus: genus }

      specify do
        expect { described_class[taxon, new_species] }.to raise_error Taxon::TaxonExists
      end
    end

    context "when the new subspecies name exists, but just as the protonym of the new subspecies" do
      let(:protonym) { create :protonym, name: create(:subspecies_name, name: 'Atta major minor') }
      let(:taxon) { create_species 'Atta minor', genus: genus, protonym: protonym }
      let(:new_species) { create_species 'Atta major', genus: genus }

      specify do
        described_class[taxon, new_species]
        new_taxon = Subspecies.find taxon.id
        expect(new_taxon.name.name).to eq 'Atta major minor'
      end
    end
  end
end
