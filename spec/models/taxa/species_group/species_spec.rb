require 'spec_helper'

describe Species do
  it "can have subspecies, which are its children" do
    species = create_species 'Atta chilensis'
    robusta = create_subspecies 'Atta chilensis robusta', species: species
    saltensis = create_subspecies 'Atta chilensis saltensis', species: species

    expect(species.subspecies).to eq [robusta, saltensis]
    expect(species.children).to eq species.subspecies
  end

  describe "#statistics" do
    let(:species) { create_species }

    context "when 0 children" do
      specify { expect(species.statistics).to eq({}) }
    end

    context "when 1 valid subspecies" do
      before { create_subspecies species: species }

      specify do
        expect(species.statistics).to eq extant: {
          subspecies: { 'valid' => 1 }
        }
      end
    end

    context "when there are extant and fossil subspecies" do
      before do
        create_subspecies species: species
        create_subspecies species: species, fossil: true
      end

      specify do
        expect(species.statistics).to eq(
          extant: { subspecies: { 'valid' => 1 } },
          fossil: { subspecies: { 'valid' => 1 } }
        )
      end
    end

    context "when 1 valid subspecies and 2 synonyms" do
      before do
        create_subspecies species: species
        2.times { create_subspecies species: species, status: 'synonym' }
      end

      specify do
        expect(species.statistics).to eq extant: {
          subspecies: { 'valid' => 1, 'synonym' => 2 }
        }
      end
    end
  end

  describe "#become_subspecies_of" do
    let(:genus) { create_genus 'Atta' }

    it "turns the record into a Subspecies" do
      taxon = create_species 'Atta minor', genus: genus
      taxon.protonym.name.name = 'Atta (Myrma) minor'
      taxon.protonym.name.save!
      new_species = create_species 'Atta major', genus: genus

      taxon.become_subspecies_of new_species
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

      taxon.become_subspecies_of new_species
      taxon = Subspecies.find taxon.id
      expect(taxon.species).to eq new_species
      expect(taxon.genus).to eq new_species.genus
      expect(taxon.subfamily).to eq new_species.subfamily
    end

    context "when the new subspecies exists" do
      let(:taxon) { create_species 'Camponotus dallatorrei', genus: genus }
      let(:new_species) { create_species 'Camponotus alii', genus: genus }

      before { create_subspecies 'Atta alii dallatorrei', genus: genus }

      it "handles it" do
        expect { taxon.become_subspecies_of new_species }.to raise_error Taxon::TaxonExists
      end
    end

    context "when the new subspecies name exists, but just as the protonym of the new subspecies" do
      let(:protonym) { create :protonym, name: create(:subspecies_name, name: 'Atta major minor') }
      let(:taxon) { create_species 'Atta minor', genus: genus, protonym: protonym }
      let(:new_species) { create_species 'Atta major', genus: genus }

      it "handles it" do
        taxon.become_subspecies_of new_species
        new_taxon = Subspecies.find taxon.id
        expect(new_taxon.name.name).to eq 'Atta major minor'
      end
    end
  end

  describe "#siblings" do
    let(:genus) { create_genus }
    let(:species) { create_species genus: genus }
    let(:another_species) { create_species genus: genus }

    it "returns itself and its genus's species" do
      expect(species.siblings).to match_array [species, another_species]
    end
  end
end
