require 'spec_helper'

describe Taxon do
  it "starts as 'old', and stays there" do
    adder = create :user, can_edit: true

    taxon = create_taxon_version_and_change :old, adder

    expect(taxon).to be_old
    expect(taxon.can_approve?).to be_falsey
  end

  it "should be able to transition from waiting to approved" do
    adder = create :user, can_edit: true

    taxon = create_taxon_version_and_change :waiting, adder
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
      @editor = create :user, can_edit: true
      @user = create :user
    end

    describe "An old record" do
      before do
        @taxon = create_taxon_version_and_change nil
      end
      it "should not allow it to be reviewed" do
        expect(@taxon.can_be_reviewed?).to be_falsey
      end
      it "should not allow it to be approved" do
        name = create :name, name: 'default_genus'
        another_taxon = create :genus, name: name
        another_taxon.taxon_state.review_state = :old

        change = create :change, user_changed_taxon_id: another_taxon.id, change_type: "create"
        create :version, item_id: another_taxon.id, whodunnit: @user.id, change_id: change.id
        change.update_attributes! approver: @user, approved_at: Time.now

        expect(@taxon.can_be_approved_by?(change, nil)).to be_falsey
        expect(@taxon.can_be_approved_by?(change, @editor)).to be_falsey
        expect(@taxon.can_be_approved_by?(change, @user)).to be_falsey
      end
    end

    describe "A waiting record" do
      before do
        @changer = create :user, can_edit: true
        @approver = create :user, can_edit: true

        name = create :name, name: 'default_genus'
        @taxon = create :genus, name: name
        @taxon.taxon_state.review_state = :waiting

        @change = create :change, user_changed_taxon_id: @taxon.id, change_type: "create"
        create :version, item_id: @taxon.id, whodunnit: @changer.id, change_id: @change.id
        @change.update_attributes! approver: @changer, approved_at: Time.now
      end
      it "should allow it to be reviewed by a catalog editor" do
        expect(@taxon.can_be_reviewed?).to be true
      end
      it "should allow it to be approved by an approver" do
        expect(@taxon.can_be_approved_by?(@change, nil)).to be_falsey
        expect(@taxon.can_be_approved_by?(@change, @approver)).to be_truthy
        expect(@taxon.can_be_approved_by?(@change, @user)).to be_falsey
      end
    end

    describe "An approved record" do
      before do
        @approver = create :user, can_edit: true
        @taxon = create_taxon_version_and_change :approved, @editor, @approver
      end
      it "should have an approver and an approved_at" do
        expect(@taxon.approver).to eq @approver
        expect(@taxon.approved_at).to be_within(7.hours).of(Time.now)
      end
      it "should not allow it to be reviewed" do
        expect(@taxon.can_be_reviewed?).to be_falsey
      end
      it "should not allow it to be approved", pending: true do
        pending "was never tested"

        expect(@taxon.can_be_approved_by?(change, nil)).to be_falsey
        expect(@taxon.can_be_approved_by?(change, @editor)).to be_falsey
        expect(@taxon.can_be_approved_by?(change, @user)).to be_falsey
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
        expect(taxon.last_change).to eq change
      end
    end
    describe "Last version" do
      it "should return the most recent Version" do
        adder = create :user, can_edit: true

        taxon = create_taxon_version_and_change :waiting, adder
        genus = taxon
        last_version = genus.last_version
        genus.reload
        expect(last_version).to eq genus.versions(true).last
      end
    end
  end

  # We no longer support "Added by" display.
  # describe "Added by" do
  #   around do |example|
  #     with_versioning &example
  #   end
  #   it "should return the User who added the record, not a subsequent editor" do
  #     adder = create :user
  #     editor = create :user
  #     taxon = create_taxon_version_and_change :waiting, adder
  #
  #     setup_version taxon.id, adder
  #
  #     taxon.update_attributes! incertae_sedis_in: 'genus'
  #     taxon.last_version.update_attributes! whodunnit: editor
  #     taxon.save!
  #     setup_version taxon.id, adder
  #
  #     expect(taxon.added_by).to eq adder
  #   end
  #
  # end

end
