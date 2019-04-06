require 'spec_helper'

describe Taxon do
  it "can transition from waiting to approved" do
    taxon = create :family
    create :change, taxon: taxon, change_type: "create"

    expect(taxon).to be_waiting
    expect(taxon.can_approve?).to be true

    taxon.approve!
    expect(taxon).to be_approved
    expect(taxon).not_to be_waiting
  end

  describe "authorization" do
    let(:adder) { create :user }
    let(:approver) { create :user }

    context "when an old record" do
      let(:taxon) { create :family, :old }
      let(:a_change) { create :change, taxon: taxon, user: adder }

      it "cannot be reviewed" do
        expect(taxon.can_be_reviewed?).to be false
      end

      it "cannot be approved" do
        expect(taxon.can_be_approved_by?(a_change, approver)).to be false
        expect(taxon.can_be_approved_by?(a_change, adder)).to be false
      end
    end

    context "when a waiting record" do
      let(:taxon) { create :family, :waiting }
      let(:a_change) { create :change, taxon: taxon, user: adder }

      it "can be reviewed by a catalog editor" do
        expect(taxon.can_be_reviewed?).to be true
      end

      it "can be approved by an approver" do
        expect(taxon.can_be_approved_by?(a_change, approver)).to be true
        expect(taxon.can_be_approved_by?(a_change, adder)).to be false
      end
    end

    context "when an approved record" do
      let(:taxon) { create :family, :approved }
      let(:a_change) { create :change, taxon: taxon, user: adder, approver: approver, approved_at: Time.current }
      let!(:version) { create :version, change_id: a_change.id, item: taxon }

      it "cannot be reviewed" do
        expect(taxon.can_be_reviewed?).to be false
      end

      it "cannot be approved" do
        expect(taxon.can_be_approved_by?(a_change, approver)).to be false
        expect(taxon.can_be_approved_by?(a_change, adder)).to be false
      end
    end
  end

  describe "#last_change" do
    let(:taxon) { create :family }

    it "returns nil if no changes have been created for it" do
      expect(taxon.last_change).to be_nil
    end

    it "returns the change, if any" do
      a_change = create :change, taxon: taxon
      create :version, item: taxon, change: a_change

      expect(taxon.last_change).to eq a_change
    end
  end
end
