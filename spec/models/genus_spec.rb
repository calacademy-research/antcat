require 'spec_helper'

describe Genus do
  it "should exist" do
    Genus.create!.should be_valid
  end
end
