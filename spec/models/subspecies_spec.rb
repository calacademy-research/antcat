require 'spec_helper'

describe Subspecies do

  it "must have a species" do
    subspecies = Subspecies.new :name => 'Colobopsis'
    subspecies.should_not be_valid
    subspecies.species = Factory :species, :name => 'christi'
    subspecies.save!
    subspecies.reload.species.name.should == 'christi'
  end

end
