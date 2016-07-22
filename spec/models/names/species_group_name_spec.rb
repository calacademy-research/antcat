require 'spec_helper'

describe SpeciesGroupName do

  describe "Species epithet" do
    it "should know its species epithet" do
      name = SpeciesName.new name: 'Atta major', epithet: 'major'
      expect(name.genus_epithet).to eq 'Atta'
      expect(name.species_epithet).to eq 'major'
    end
  end

end
