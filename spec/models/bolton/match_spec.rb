require 'spec_helper'

describe Bolton::Match do
  it "can have a reference" do
    match = Bolton::Match.create!
    match.reference = FactoryGirl.create :reference
  end

  it "can have a Bolton reference" do
    match = Bolton::Match.create!
    match.bolton_reference = FactoryGirl.create :bolton_reference
  end
end
