require 'spec_helper'

describe Tribe do
  let(:tribe) { create :tribe, subfamily: subfamily }
  let(:subfamily) { create :subfamily }

  it { is_expected.to validate_presence_of :subfamily }

  describe 'relations' do
    it { is_expected.to have_many(:subtribes).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:genera).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:species).dependent(:restrict_with_error) }
  end

  it "can have genera, which are its children" do
    genus = create :genus, tribe: tribe
    another_genus = create :genus, tribe: tribe

    expect(tribe.genera).to eq [genus, another_genus]
    expect(tribe.children).to eq tribe.genera
  end

  describe "#update_parent" do
    let!(:new_subfamily) { create :subfamily }

    it "assigns the subfamily when parent is a tribe" do
      tribe.update_parent new_subfamily
      expect(tribe.subfamily).to eq new_subfamily
    end

    it "assigns the subfamily of its descendants" do
      genus = create :genus, tribe: tribe
      species = create :species, genus: genus
      create :subspecies, species: species, genus: genus

      # Test initial.
      expect(tribe.subfamily).to eq subfamily
      expect(tribe.reload.genera.first.subfamily).to eq subfamily
      expect(tribe.reload.genera.first.species.first.subfamily).to eq subfamily
      expect(tribe.reload.genera.first.subspecies.first.subfamily).to eq subfamily

      # Act.
      tribe.update_parent new_subfamily
      tribe.save!

      # Assert.
      expect(tribe.reload.subfamily).to eq new_subfamily
      expect(tribe.reload.genera.first.subfamily).to eq new_subfamily
      expect(tribe.reload.genera.first.species.first.subfamily).to eq new_subfamily
      expect(tribe.reload.genera.first.subspecies.first.subfamily).to eq new_subfamily
    end
  end
end
