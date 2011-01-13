require 'spec_helper'

describe Antweb::Taxonomy do
  it "should be able to get fossil?" do
    genus = Antweb::Taxonomy.create!
    genus.update_attributes :fossil => true
    genus.fossil?.should be_true
  end
end
