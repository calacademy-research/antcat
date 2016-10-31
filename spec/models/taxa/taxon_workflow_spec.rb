require 'spec_helper'

describe Taxon do
  let(:adder) { create :editor }

  it "starts as 'old', and stays there" do
    taxon = create_taxon_version_and_change :old, adder

    expect(taxon).to be_old
    expect(taxon.can_approve?).to be_falsey
  end

  it "should be able to transition from waiting to approved" do
    taxon = create_taxon_version_and_change :waiting, adder
    expect(taxon).to be_waiting
    expect(taxon.can_approve?).to be_truthy

    taxon.approve!
    expect(taxon).to be_approved
    expect(taxon).not_to be_waiting
  end

  describe "Authorization", versioning: true do
    let(:editor) { create :editor }
    let(:user) { create :user }
    let(:approver) { create :editor }

    describe "An old record" do
      let!(:taxon) { create_taxon_version_and_change nil, user }

      it "should not allow it to be reviewed" do
        expect(taxon.can_be_reviewed?).to be_falsey
      end

      it "should not allow it to be approved" do
        name = create :name, name: 'default_genus'
        another_taxon = create :genus, name: name
        another_taxon.taxon_state.review_state = :old

        change = create :change, user_changed_taxon_id: another_taxon.id, change_type: "create"
        create :version, item_id: another_taxon.id, whodunnit: user.id, change_id: change.id
        change.update_attributes! approver: user, approved_at: Time.now

        expect(taxon.can_be_approved_by?(change, nil)).to be_falsey
        expect(taxon.can_be_approved_by?(change, editor)).to be_falsey
        expect(taxon.can_be_approved_by?(change, user)).to be_falsey
      end
    end

    describe "A waiting record" do
      let(:changer) { create :editor }

      before do
        @taxon = create :genus, name: create(:name, name: 'default_genus')
        @taxon.taxon_state.review_state = :waiting

        @change = create :change, user_changed_taxon_id: @taxon.id, change_type: "create"
        create :version, item_id: @taxon.id, whodunnit: changer.id, change_id: @change.id
        @change.update_attributes! approver: approver, approved_at: Time.now
      end

      it "should allow it to be reviewed by a catalog editor" do
        expect(@taxon.can_be_reviewed?).to be true
      end

      it "should allow it to be approved by an approver" do
        expect(@taxon.can_be_approved_by?(@change, nil)).to be_falsey
        expect(@taxon.can_be_approved_by?(@change, approver)).to be_truthy
        expect(@taxon.can_be_approved_by?(@change, user)).to be_falsey
      end
    end

    describe "An approved record" do
      before { @taxon = create_taxon_version_and_change :approved, editor, approver }

      it "should have an approver and an approved_at" do
        expect(@taxon.approver).to eq approver
        expect(@taxon.approved_at).to be_within(7.hours).of(Time.now)
      end

      it "should not allow it to be reviewed" do
        expect(@taxon.can_be_reviewed?).to be_falsey
      end

      it "should not allow it to be approved", pending: true do
        pending "was never tested"

        expect(@taxon.can_be_approved_by?(change, nil)).to be_falsey
        expect(@taxon.can_be_approved_by?(change, editor)).to be_falsey
        expect(@taxon.can_be_approved_by?(change, user)).to be_falsey
      end
    end
  end

  describe "Last change and version", versioning: true do
    describe "#last_change" do
      let(:taxon) { create_genus }

      it "returns nil if no Changes have been created for it" do
        expect(taxon.last_change).to be_nil
      end

      it "returns the Change, if any" do
        change = setup_version taxon.id
        expect(taxon.last_change).to eq change
      end
    end

    describe "#last_version" do
      it "returns the most recent Version" do
        genus = create_taxon_version_and_change :waiting, adder

        last_version = genus.last_version
        genus.reload
        expect(last_version).to eq genus.versions(true).last
      end
    end
  end

  # We no longer support "Added by" display.
  # describe "Added by" do
  #   it "should return the User who added the record, not a subsequent editor" do
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
  # end
end
