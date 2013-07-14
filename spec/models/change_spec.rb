# coding: UTF-8
require 'spec_helper'

describe Change do
  it "has a version" do
    genus = create_genus
    change = Change.new
    change.version = genus.version
    change.save!
    change.reload
    change.version.should == genus.version
    change.version.should be_nil
  end
end
