# coding: UTF-8
require 'spec_helper'

describe Change do

  it "has a version" do
    genus = create_genus
    change = Change.new
    change.paper_trail_version = genus.version
    change.save!
    change.reload
    change.paper_trail_version.should == genus.version
    change.paper_trail_version.should be_nil
  end
  end
end
