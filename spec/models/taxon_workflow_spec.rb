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

  def create_taxon_version_and_change review_state
    taxon = FactoryGirl.create :genus, review_state: review_state
    taxon.last_version.update_attributes! whodunnit: @user
    Change.create! paper_trail_version: taxon.last_version
    taxon
  end

  describe "Ability to be edited" do
    around do |example|
      with_versioning &example
    end
    before do
      @user = FactoryGirl.create :user
    end
    it "should allow an old record to be edited" do
      taxon = create_taxon_version_and_change nil
      taxon.can_be_edited_by?(@user).should be_true
    end
    it "should allow an approved record to be edited" do
      taxon = create_taxon_version_and_change :approved
      taxon.can_be_edited_by?(@user).should be_true
    end
    it "should not allow anyone not the editor to edit a waiting record" do
      taxon = create_taxon_version_and_change :waiting
      another_user = FactoryGirl.create :user
      taxon.can_be_edited_by?(@user).should be_true
      taxon.can_be_edited_by?(another_user).should be_false
    end
  end

  describe "Ability to be reviewed" do
    around do |example|
      with_versioning &example
    end
    before do
      @user = FactoryGirl.create :user
    end
    it "should not allow an old record to be reviewed" do
      taxon = create_taxon_version_and_change nil
      taxon.can_be_reviewed_by?(@user).should be_false
    end
    it "should allow an waiting record to be reviewed" do
      taxon = create_taxon_version_and_change :waiting
      taxon.can_be_edited_by?(@user).should be_true
    end
    it "should not allow an approved record to be reviewed" do
      taxon = create_taxon_version_and_change :approved
      taxon.can_be_edited_by?(@user).should be_true
    end
  end

  describe "Last change and version" do
    around do |example|
      with_versioning &example
    end
    describe "Last change" do
      it "should return nil if no Changes have been created for it" do
        taxon = create_genus
        taxon.last_change.should be_nil
      end
      it "should return the Change, if any" do
        taxon = create_genus
        change = Change.create! paper_trail_version: taxon.last_version
        taxon.last_change.should == change
      end
    end
    describe "Last version" do
      it "should return the most recent Version" do
        genus = create_genus
        last_version = genus.last_version
        genus.reload
        last_version.should == genus.versions(true).last
      end
    end
  end

end
