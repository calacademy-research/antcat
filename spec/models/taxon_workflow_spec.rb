# coding: UTF-8
require 'spec_helper'

describe Taxon do
  it "starts as 'old', and stays there" do
    taxon = FactoryGirl.create :genus
    taxon.should be_old
    taxon.can_approve?.should be_false
  end 

  it "should be able to transition from waiting to approved" do
    taxon = FactoryGirl.create :genus, review_state: :waiting
    taxon.should be_waiting
    taxon.can_approve?.should be_true
    taxon.approve!
    taxon.should be_approved
    taxon.should_not be_waiting
  end 

  describe "Ability to be edited" do
    it "should manage an old record's 'can be edited' status" do
      taxon = FactoryGirl.create :genus, review_state: nil
      taxon.can_be_edited?.should be_true
    end 
    it "should manage a record with a Change's 'can be edited' status" do
      taxon = FactoryGirl.create :genus, review_state: :approved
      taxon.can_be_edited?.should be_true
    end 
    it "should manage a waiting record with a Change's 'can be edited' status" do
      taxon = FactoryGirl.create :genus, review_state: :waiting
      taxon.can_be_edited?.should be_false
    end 
  end

  describe "Last change" do
    it "should return the last change" do
      with_versioning do
        taxon = create_genus
        change = Change.create! paper_trail_version: taxon.versions(true).last
        taxon.last_change.should == change
      end
    end
  end

end
