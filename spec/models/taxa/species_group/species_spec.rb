require 'rails_helper'

describe Species do
  it { is_expected.to validate_presence_of :genus }

  describe 'relations' do
    it { is_expected.to have_many(:subspecies).dependent(:restrict_with_error) }
  end

  it "can have subspecies, which are its children" do
    species = create :species
    robusta = create :subspecies, species: species
    saltensis = create :subspecies, species: species

    expect(species.subspecies).to eq [robusta, saltensis]
    expect(species.children).to eq species.subspecies
  end

  describe "#update_parent" do
    let!(:subfamily) { create :subfamily }
    let!(:genus) { create :genus, subfamily: subfamily }
    let!(:species) { create :species, subfamily: subfamily, genus: genus }

    it "assigns the subfamily of its descendants" do
      subspecies = create :subspecies, species: species, genus: genus, subfamily: subfamily
      new_genus = create :genus

      expect(new_genus.subfamily).to_not eq subfamily

      # Test initial.
      expect(species.reload.subfamily).to eq subfamily
      expect(species.reload.genus).to eq genus
      expect(subspecies.reload.genus).to eq genus
      expect(subspecies.reload.subfamily).to eq subfamily

      # Act.
      species.update_parent new_genus
      species.save!

      # Assert.
      expect(species.reload.subfamily).to eq new_genus.subfamily
      expect(species.reload.genus).to eq new_genus
      expect(subspecies.reload.genus).to eq new_genus
      expect(subspecies.reload.subfamily).to eq new_genus.subfamily
    end
  end
end
