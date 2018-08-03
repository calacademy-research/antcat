require 'spec_helper'

describe Taxon do # rubocop:disable RSpec/FilePath
  let(:taxon) { build_stubbed :taxon }

  context "when status 'valid'" do
    it "is not invalid" do
      taxon.status = Status::VALID
      expect(taxon).not_to be_invalid
    end
  end

  it "can be unidentifiable" do
    expect(taxon).not_to be_unidentifiable
    taxon.status = Status::UNIDENTIFIABLE
    expect(taxon).to be_unidentifiable
    expect(taxon).to be_invalid
  end

  it "can be a collective group name" do
    expect(taxon).not_to be_collective_group_name
    taxon.status = Status::COLLECTIVE_GROUP_NAME
    expect(taxon).to be_collective_group_name
    expect(taxon).to be_invalid
  end

  it "can be an ichnotaxon" do
    expect(taxon).not_to be_ichnotaxon
    taxon.ichnotaxon = true
    expect(taxon).to be_ichnotaxon
    expect(taxon).not_to be_invalid
  end

  it "can be a fossil" do
    expect(taxon).not_to be_fossil
    expect(taxon.fossil).to eq false
    taxon.fossil = true
    expect(taxon).to be_fossil
  end

  describe "#recombination?" do
    context "when name is same as protonym" do
      let!(:species) { create_species 'Atta major' }
      let!(:protonym_name) { create :species_name, name: 'Atta major' }

      it "is not a recombination" do
        expect(species.protonym).to receive(:name).and_return protonym_name
        expect(species).not_to be_recombination
      end
    end

    context "when genus part of name is different than genus part of protonym" do
      let!(:species) { create_species 'Atta minor' }
      let!(:protonym_name) { create :species_name, name: 'Eciton minor' }

      it "is a recombination" do
        expect(species.protonym).to receive(:name).and_return protonym_name
        expect(species).to be_recombination
      end
    end

    context "when genus part of name is same as genus part of protonym" do
      let!(:species) { create_species 'Atta minor maxus' }
      let!(:protonym_name) { create :subspecies_name, name: 'Atta minor minus' }

      it "is not a recombination" do
        expect(species.protonym).to receive(:name).and_return protonym_name
        expect(species).not_to be_recombination
      end
    end
  end
end
