require 'spec_helper'

describe Species do
  it "should exist" do
    Species.create!.should be_valid
  end
end
