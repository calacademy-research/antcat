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

  it "should be able to be reified after being created" do
    with_versioning do
      genus = create_genus

      change = Change.new paper_trail_version: genus.versions(true).last
      taxon = change.reify
      taxon.should == genus
      taxon.class.should == Genus

      genus.update_attributes name_cache: 'Atta'

      change = Change.new paper_trail_version: genus.versions(true).last
      taxon = change.reify
      taxon.should == genus
      taxon.class.should == Genus

    end
  end
end
