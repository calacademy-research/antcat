# coding: UTF-8
require 'spec_helper'

describe Taxon do
  it "starts as 'old', and stays there" do
    taxon = FactoryGirl.create :genus
    expect(taxon).to be_old
    expect(taxon.can_approve?).to be_falsey
  end

  it "should be able to transition from waiting to approved" do
    taxon = FactoryGirl.create :genus, review_state: :waiting
    expect(taxon).to be_waiting
    expect(taxon.can_approve?).to be_truthy
    taxon.approve!
    expect(taxon).to be_approved
    expect(taxon).not_to be_waiting
  end

  describe "Authorization" do
    around do |example|
      with_versioning &example
    end
    before do
      @editor = FactoryGirl.create :user, can_edit: true
      @user = FactoryGirl.create :user
    end

    describe "An old record" do
      before do
        @taxon = create_taxon_version_and_change nil
      end
      it "should allow it to be edited by any user that can edit the catalog" do
        expect(@taxon.can_be_edited_by?(nil)).to be_falsey
        expect(@taxon.can_be_edited_by?(@editor)).to be_truthy
        expect(@taxon.can_be_edited_by?(@user)).to be_falsey
      end
      it "should not allow it to be reviewed" do
        expect(@taxon.can_be_reviewed_by?(nil)).to be_falsey
        expect(@taxon.can_be_reviewed_by?(@editor)).to be_falsey
        expect(@taxon.can_be_reviewed_by?(@user)).to be_falsey
      end
      it "should not allow it to be approved" do
        expect(@taxon.can_be_reviewed_by?(nil)).to be_falsey
        expect(@taxon.can_be_reviewed_by?(@editor)).to be_falsey
        expect(@taxon.can_be_reviewed_by?(@user)).to be_falsey
      end
    end

    describe "A waiting record" do
      before do
        @changer = FactoryGirl.create :user, can_edit: true
        @approver = FactoryGirl.create :user, can_edit: true
        @taxon = create_taxon_version_and_change :waiting, @changer
      end
      it "should allow any user to edit a waiting record" do
        expect(@taxon.can_be_edited_by?(nil)).to be_falsey
        expect(@taxon.can_be_edited_by?(@user)).to be_falsey
        expect(@taxon.can_be_edited_by?(@editor)).to be_truthy
        expect(@taxon.can_be_edited_by?(@changer)).to be_truthy
      end
      it "should allow it to be reviewed by a catalog editor" do
        expect(@taxon.can_be_reviewed_by?(nil)).to be_falsey
        expect(@taxon.can_be_reviewed_by?(@editor)).to be_truthy
        expect(@taxon.can_be_reviewed_by?(@user)).to be_falsey
      end
      it "should allow it to be approved by an approver" do
        expect(@taxon.can_be_approved_by?(nil)).to be_falsey
        expect(@taxon.can_be_approved_by?(@approver)).to be_truthy
        expect(@taxon.can_be_approved_by?(@user)).to be_falsey
      end
    end

    describe "An approved record" do
      before do
        @approver = FactoryGirl.create :user, can_edit: true
        @taxon = create_taxon_version_and_change :approved, @editor, @approver
      end
      it "should have an approver and an approved_at" do
        expect(@taxon.approver).to eq(@approver)
        expect(@taxon.approved_at).to be_within(7.hours).of(Time.now)
      end
      it "should allow it to be edited by any user that can edit the catalog" do
        expect(@taxon.can_be_edited_by?(nil)).to be_falsey
        expect(@taxon.can_be_edited_by?(@editor)).to be_truthy
        expect(@taxon.can_be_edited_by?(@user)).to be_falsey
      end
      it "should not allow it to be reviewed" do
        expect(@taxon.can_be_reviewed_by?(nil)).to be_falsey
        expect(@taxon.can_be_reviewed_by?(@editor)).to be_falsey
        expect(@taxon.can_be_reviewed_by?(@user)).to be_falsey
      end
      it "should not allow it to be approved" do
        expect(@taxon.can_be_reviewed_by?(nil)).to be_falsey
        expect(@taxon.can_be_reviewed_by?(@editor)).to be_falsey
        expect(@taxon.can_be_reviewed_by?(@user)).to be_falsey
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
        expect(taxon.last_change).to be_nil
      end
      it "should return the Change, if any" do
        taxon = create_genus

        change = setup_version taxon.id
        expect(taxon.last_change).to eq(change)
      end
    end
    describe "Last version" do
      it "should return the most recent Version" do
        genus = create_genus
        last_version = genus.last_version
        genus.reload
        expect(last_version).to eq(genus.versions(true).last)
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
      editor = FactoryGirl.create :user
      setup_version taxon.id, adder

      taxon.update_attributes! incertae_sedis_in: 'genus'
      taxon.last_version.update_attributes! whodunnit: editor
      taxon.save!
      setup_version(taxon.id, adder)

      expect(taxon.added_by).to eq(adder)
    end

  end



end
