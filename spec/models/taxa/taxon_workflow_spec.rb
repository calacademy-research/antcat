require 'spec_helper'

describe Taxon do
  let(:adder) { create :user, :editor }

  it "can transition from waiting to approved" do
    taxon = create_taxon_version_and_change TaxonState::WAITING, adder
    expect(taxon).to be_waiting
    expect(taxon.can_approve?).to be true

    taxon.approve!
    expect(taxon).to be_approved
    expect(taxon).not_to be_waiting
  end

  describe "Authorization", :versioning do
    let(:editor) { create :user, :editor }
    let(:user) { create :user }
    let(:approver) { create :user, :editor }

    context "when an old record" do
      let!(:taxon) { create_taxon_version_and_change nil, user }

      it "cannot be reviewed" do
        expect(taxon.can_be_reviewed?).to be false
      end

      it "cannot be approved" do
        another_taxon = create :genus
        another_taxon.taxon_state.review_state = TaxonState::OLD

        change = create :change, taxon: another_taxon, user: adder,
          change_type: "create", approver: user, approved_at: Time.current
        create :version, item: another_taxon, whodunnit: user.id, change: change

        expect(taxon.can_be_approved_by?(change, nil)).to be false
        expect(taxon.can_be_approved_by?(change, editor)).to be false
        expect(taxon.can_be_approved_by?(change, user)).to be false
      end
    end

    context "when a waiting record" do
      let(:changer) { create :user, :editor }
      let(:taxon) { create :genus }
      let(:change) do
        create :change, taxon: taxon, user: changer,
          change_type: "create", approver: approver, approved_at: Time.current
      end

      before do
        taxon.taxon_state.review_state = TaxonState::WAITING
        create :version, item: taxon, whodunnit: changer.id, change: change
      end

      it "can be reviewed by a catalog editor" do
        expect(taxon.can_be_reviewed?).to be true
      end

      it "can be approved by an approver" do
        expect(taxon.can_be_approved_by?(change, nil)).to be false
        expect(taxon.can_be_approved_by?(change, approver)).to be true
        expect(taxon.can_be_approved_by?(change, user)).to be false
      end
    end

    context "when an approved record" do
      let(:taxon) { create_taxon_version_and_change TaxonState::APPROVED, editor, approver }

      it "has an approver and an approved_at" do
        expect(taxon.approver).to eq approver
        expect(taxon.approved_at).to be_within(7.hours).of Time.current
      end

      it "cannot be reviewed" do
        expect(taxon.can_be_reviewed?).to be false
      end

      it "cannot be approved" do
        expect(taxon.can_be_approved_by?(change, nil)).to be false
        expect(taxon.can_be_approved_by?(change, editor)).to be false
        expect(taxon.can_be_approved_by?(change, user)).to be false
      end
    end
  end

  describe "Last change and version", :versioning do
    describe "#last_change" do
      let(:taxon) { create_genus }
      let(:user) { create :user }

      it "returns nil if no Changes have been created for it" do
        expect(taxon.last_change).to be_nil
      end

      it "returns the Change, if any" do
        change = setup_version taxon, user
        expect(taxon.last_change).to eq change
      end
    end
  end
end
