# coding: UTF-8
require 'spec_helper'

describe SpeciesGroupName do

  it "should know how many epithets it has" do
    subspecies = create_subspecies 'Crematogaster stambulovi taurica salina'
    subspecies.name.epithet_count.should == 3
  end

end
