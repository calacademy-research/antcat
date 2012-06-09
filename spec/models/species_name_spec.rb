# coding: UTF-8
require 'spec_helper'

describe SpeciesName do

  describe "Importing" do
    it "should assemble the name from the genus and species epithet" do
      name = SpeciesName.new.import '', genus_name: 'Atta', species_epithet: 'major'
      name.name.should == 'Atta major'
    end
  end

end
