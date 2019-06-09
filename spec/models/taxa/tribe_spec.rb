require 'spec_helper'

describe Tribe do
  let(:tribe) { create :tribe, subfamily: subfamily }
  let(:subfamily) { create :subfamily }

  it { is_expected.to validate_presence_of :subfamily }

  it "can have genera, which are its children" do
    genus = create :genus, tribe: tribe
    another_genus = create :genus, tribe: tribe

    expect(tribe.genera).to eq [genus, another_genus]
    expect(tribe.children).to eq tribe.genera
  end

  describe "#update_parent" do
    let(:new_subfamily) { create :subfamily }

    it "assigns the subfamily when parent is a tribe" do
      tribe.update_parent new_subfamily
      expect(tribe.subfamily).to eq new_subfamily
    end

    it "assigns the subfamily of its descendants" do
      genus = create :genus, tribe: tribe
      species = create :species, genus: genus
      create :subspecies, species: species, genus: genus

      # test the initial subfamilies
      expect(tribe.subfamily).to eq subfamily
      expect(tribe.genera.first.subfamily).to eq subfamily
      expect(tribe.genera.first.species.first.subfamily).to eq subfamily
      expect(tribe.genera.first.subspecies.first.subfamily).to eq subfamily

      # test the updated subfamilies
      tribe.update_parent new_subfamily
      expect(tribe.subfamily).to eq new_subfamily
      expect(tribe.genera.first.subfamily).to eq new_subfamily
      expect(tribe.genera.first.species.first.subfamily).to eq new_subfamily
      expect(tribe.genera.first.subspecies.first.subfamily).to eq new_subfamily
    end
  end
end
