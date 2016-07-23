require 'spec_helper'

describe SpeciesGroupName do
  let(:name) { SpeciesName.new name: 'Atta major', epithet: 'major' }

  describe "#genus_epithet" do
    it "knows its genus epithet" do
      expect(name.genus_epithet).to eq 'Atta'
    end
  end

  describe "#species_epithet" do
    it "knows its species epithet" do
      expect(name.species_epithet).to eq 'major'
    end
  end
end
