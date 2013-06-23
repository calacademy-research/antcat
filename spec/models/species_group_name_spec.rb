# coding: UTF-8
require 'spec_helper'

describe SpeciesGroupName do

  it "should know how many epithets it has" do
    subspecies = create_subspecies 'Crematogaster stambulovi taurica salina'
    subspecies.name.epithet_count.should == 3
  end

  describe "Species epithet" do
    it "should know its species epithet" do
      name = SpeciesName.new name: 'Atta major', epithet: 'major'
      name.genus_epithet.should == 'Atta'
      name.species_epithet.should == 'major'
    end
  end

end
