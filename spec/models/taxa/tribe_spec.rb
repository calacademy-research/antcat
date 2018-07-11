require 'spec_helper'

describe Tribe do
  it { is_expected.to belong_to :subfamily }

  let(:subfamily) { create :subfamily, name: create(:name, name: 'Myrmicinae')}
  let(:tribe) { create :tribe, name: create(:name, name: 'Attini'), subfamily: subfamily }

  it "can have genera, which are its children" do
    atta = create :genus, name: create(:name, name: 'Acromyrmex'), tribe: tribe
    acromyrmex = create :genus, name: create(:name, name: 'Atta'), tribe: tribe

    expect(tribe.genera).to eq [atta, acromyrmex]
    expect(tribe.children).to eq tribe.genera
  end

  describe "#siblings" do
    it "returns itself and its subfamily's other tribes" do
      another_tribe = create :tribe, subfamily: subfamily
      expect(tribe.siblings).to match_array [tribe, another_tribe]
    end
  end

  describe "#statistics" do
    it "includes the number of genera" do
      create :genus, tribe: tribe
      expect(tribe.statistics).to eq extant: { genera: { 'valid' => 1 } }
    end

    it "includes the number of species" do
      genus = create :genus, tribe: tribe
      create :species, genus: genus
      create :species, genus: genus, status: Status::SYNONYM

      expect(tribe.statistics).to eq extant: {
        genera: {"valid" => 1},
        species: {"synonym" => 1, "valid" => 1}
      }
    end
  end

  describe "#update_parent" do
    let(:new_subfamily) {  create :subfamily }

    it "assigns the subfamily when parent is a tribe" do
      tribe.update_parent new_subfamily
      expect(tribe.subfamily).to eq new_subfamily
    end

    it "assigns the subfamily of its descendants" do
      genus = create_genus tribe: tribe
      species = create_species genus: genus
      create_subspecies species: species, genus: genus

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
