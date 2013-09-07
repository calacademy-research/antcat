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

  describe "Authorization" do
    around do |example|
      with_versioning &example
    end
    before do
      @editor = FactoryGirl.create :user, can_edit_catalog: true
      @user = FactoryGirl.create :user
    end

    describe "An old record" do
      before do
        @taxon = create_taxon_version_and_change nil
      end
      it "should allow it to be edited by any user that can edit the catalog" do
        @taxon.can_be_edited_by?(nil).should be_false
        @taxon.can_be_edited_by?(@editor).should be_true
        @taxon.can_be_edited_by?(@user).should be_false
      end
      it "should not allow it to be reviewed" do
        @taxon.can_be_reviewed_by?(nil).should be_false
        @taxon.can_be_reviewed_by?(@editor).should be_false
        @taxon.can_be_reviewed_by?(@user).should be_false
      end
      it "should not allow it to be approved" do
        @taxon.can_be_reviewed_by?(nil).should be_false
        @taxon.can_be_reviewed_by?(@editor).should be_false
        @taxon.can_be_reviewed_by?(@user).should be_false
      end
    end

    describe "A waiting record" do
      before do
        @changer = FactoryGirl.create :user, can_edit_catalog: true
        @approver = FactoryGirl.create :user, can_edit_catalog: true
        @taxon = create_taxon_version_and_change :waiting, @changer
      end
      it "should only allow the user who made the change to edit a waiting record" do
        @taxon.can_be_edited_by?(nil).should be_false
        @taxon.can_be_edited_by?(@user).should be_false
        @taxon.can_be_edited_by?(@editor).should be_false
        @taxon.can_be_edited_by?(@changer).should be_true
      end
      it "should allow it to be reviewed by a catalog editor" do
        @taxon.can_be_reviewed_by?(nil).should be_false
        @taxon.can_be_reviewed_by?(@editor).should be_true
        @taxon.can_be_reviewed_by?(@user).should be_false
      end
      it "should allow it to be approved by an approver" do
        @taxon.can_be_approved_by?(nil).should be_false
        @taxon.can_be_approved_by?(@approver).should be_true
        @taxon.can_be_approved_by?(@user).should be_false
      end
    end

    describe "An approved record" do
      before do
        @approver = FactoryGirl.create :user, can_edit_catalog: true
        @taxon = create_taxon_version_and_change :approved, @editor, @approver
      end
      it "should have an approver and an approved_at" do
        @taxon.approver.should == @approver
        @taxon.approved_at.should be_within(7.hours).of(Time.now)
      end
      it "should allow it to be edited by any user that can edit the catalog" do
        @taxon.can_be_edited_by?(nil).should be_false
        @taxon.can_be_edited_by?(@editor).should be_true
        @taxon.can_be_edited_by?(@user).should be_false
      end
      it "should not allow it to be reviewed" do
        @taxon.can_be_reviewed_by?(nil).should be_false
        @taxon.can_be_reviewed_by?(@editor).should be_false
        @taxon.can_be_reviewed_by?(@user).should be_false
      end
      it "should not allow it to be approved" do
        @taxon.can_be_reviewed_by?(nil).should be_false
        @taxon.can_be_reviewed_by?(@editor).should be_false
        @taxon.can_be_reviewed_by?(@user).should be_false
      end
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

  describe "Added by" do
    around do |example|
      with_versioning &example
    end
    it "should return the User who added the record, not a subsequent editor" do
      taxon = create_genus

      adder = FactoryGirl.create :user
      taxon.last_version.update_attributes! whodunnit: adder
      Change.create! paper_trail_version: taxon.last_version

      editor = FactoryGirl.create :user
      taxon.update_attributes! incertae_sedis_in: 'genus'
      taxon.last_version.update_attributes! whodunnit: editor
      Change.create! paper_trail_version: taxon.last_version

      taxon.added_by.should == adder
    end

  end

end
