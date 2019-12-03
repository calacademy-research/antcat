require 'rails_helper'

describe Subspecies do
  let(:genus) { create :genus }

  it { is_expected.to validate_presence_of :genus }
  it { is_expected.to validate_presence_of :species }

  it "has its subfamily assigned from its genus" do
    subspecies = create :subspecies, genus: genus, subfamily: nil
    expect(subspecies.subfamily).to eq genus.subfamily
  end

  it "has its genus assigned from its species" do
    species = create :species, genus: genus
    subspecies = create :subspecies, genus: nil, species: species

    expect(subspecies.genus).to eq genus
  end

  describe "#update_parent" do
    let(:subspecies) { create :subspecies }
    let(:new_parent) { create :species }

    it "sets all the parent fields" do
      subspecies.update_parent new_parent
      subspecies.save!

      expect(subspecies.reload.species).to eq new_parent
      expect(subspecies.reload.genus).to eq new_parent.genus
      expect(subspecies.reload.subgenus).to eq new_parent.subgenus
      expect(subspecies.reload.subfamily).to eq new_parent.subfamily
    end

    describe "updating the name" do
      let(:subspecies) { create :subspecies, name_string: 'Atta major medius minor' }
      let(:new_parent) { create :species, name_string: 'Eciton nigrus' }

      specify do
        subspecies.update_parent new_parent

        subspecies_name = subspecies.name
        expect(subspecies_name.name).to eq 'Eciton nigrus medius minor'
        expect(subspecies_name.epithet).to eq 'minor'
        expect(subspecies_name.epithets).to eq 'nigrus medius minor'
      end
    end
  end
end
