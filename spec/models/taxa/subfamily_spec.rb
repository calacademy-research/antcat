require 'spec_helper'

describe Subfamily do
  it { is_expected.to have_many :collective_group_names }
  it { is_expected.to have_many :genera }
  it { is_expected.to have_many :species }
  it { is_expected.to have_many :subspecies }

  let(:subfamily) { create :subfamily, name: create(:subfamily_name, name: 'Dolichoderinae') }

  it "can have tribes, which are its children" do
    attini = create :tribe, name: create(:name, name: 'Attini'), subfamily: subfamily
    dacetini = create :tribe, name: create(:name, name: 'Dacetini'), subfamily: subfamily

    expect(subfamily.tribes).to eq [attini, dacetini]
    expect(subfamily.tribes).to eq subfamily.children
  end

  describe "#statistics" do
    context "when 0 children" do
      specify { expect(subfamily.statistics).to eq({}) }
    end

    context "when 1 valid genus" do
      before { create :genus, subfamily: subfamily }

      specify do
        expect(subfamily.statistics).to eq extant: { genera: { 'valid' => 1 } }
      end
    end

    context "when 1 valid genus and 2 synonyms" do
      before do
        create :genus, subfamily: subfamily
        2.times { create :genus, :synonym, subfamily: subfamily }
      end

      specify do
        expect(subfamily.statistics).to eq extant: {
          genera: { 'valid' => 1, 'synonym' => 2 }
        }
      end
    end

    context "when 1 valid genus with 2 valid species" do
      before do
        genus = create :genus, subfamily: subfamily
        2.times { create :species, genus: genus, subfamily: subfamily }
      end

      specify do
        expect(subfamily.statistics).to eq extant: {
          genera: { 'valid' => 1 },
          species: { 'valid' => 2 }
        }
      end
    end

    context "when 1 valid genus with 2 valid species, one of which has a subspecies" do
      before do
        genus = create :genus, subfamily: subfamily
        create :species, genus: genus
        create :subspecies, genus: genus, species: create(:species, genus: genus)
      end

      specify do
        expect(subfamily.statistics).to eq extant: {
          genera: { 'valid' => 1 },
          species: { 'valid' => 2 },
          subspecies: { 'valid' => 1 }
        }
      end
    end

    context "when there are extinct genera, species and subspecies" do
      before do
        genus = create :genus, subfamily: subfamily
        create :genus, subfamily: subfamily, fossil: true
        create :species, genus: genus
        create :species, genus: genus, fossil: true
        create :subspecies, genus: genus, species: create(:species, genus: genus)
        create :subspecies, genus: genus, species: create(:species, genus: genus), fossil: true
      end

      it "differentiates between extinct genera, species and subspecies" do
        expect(subfamily.statistics).to eq(
          extant: {
            genera: { 'valid' => 1 },
            species: { 'valid' => 3 },
            subspecies: { 'valid' => 1 }
          },
          fossil: {
            genera: { 'valid' => 1 },
            species: { 'valid' => 1 },
            subspecies: { 'valid' => 1 }
          }
        )
      end
    end

    it "can count tribes" do
      create :tribe, subfamily: subfamily
      expect(subfamily.statistics).to eq extant: { tribes: { 'valid' => 1 } }
    end
  end
end
