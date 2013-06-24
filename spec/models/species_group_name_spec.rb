# coding: UTF-8
require 'spec_helper'

describe SpeciesGroupName do

  describe "Species epithet" do
    it "should know its species epithet" do
      name = SpeciesName.new name: 'Atta major', epithet: 'major'
      name.genus_epithet.should == 'Atta'
      name.species_epithet.should == 'major'
    end
  end

end
