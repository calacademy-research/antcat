require 'spec_helper'

describe Genus do
  it "should be able to get fossil?" do
    genus = Genus.create!
    genus.update_attributes :fossil => true
    genus.fossil?.should be_true
  end
end
