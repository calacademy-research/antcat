require 'spec_helper'

describe ChangeDecorator do
  let(:user) { build_stubbed :user, name: "First Last", email: "email@example.com" }

  describe "#format_adder_name" do
    let(:change) { build_stubbed :change, approver: user, change_type: "create" }

    specify do
      allow(change).to receive(:changed_by).and_return user
      expect(change.decorate.format_adder_name).to match /First Last.*? added/
    end
  end

  describe "authorization" do
    let(:adder) { create :user }
    let(:approver) { create :user }

    context "when an old record" do
      let(:taxon) { create :family, :old }
      let(:a_change) { create :change, taxon: taxon, user: adder }

      it "cannot be approved" do
        expect(a_change.decorate.can_be_approved_by?(taxon, approver)).to be false
        expect(a_change.decorate.can_be_approved_by?(taxon, adder)).to be false
      end
    end

    context "when a waiting record" do
      let(:taxon) { create :family, :waiting }
      let(:a_change) { create :change, taxon: taxon, user: adder }

      it "can be approved by an approver" do
        expect(a_change.decorate.can_be_approved_by?(taxon, approver)).to be true
        expect(a_change.decorate.can_be_approved_by?(taxon, adder)).to be false
      end
    end

    context "when an approved record" do
      let(:taxon) { create :family, :approved }
      let(:a_change) { create :change, taxon: taxon, user: adder, approver: approver, approved_at: Time.current }

      before do
        create :version, change_id: a_change.id, item: taxon
      end

      it "cannot be approved" do
        expect(a_change.decorate.can_be_approved_by?(taxon, approver)).to be false
        expect(a_change.decorate.can_be_approved_by?(taxon, adder)).to be false
      end
    end
  end
end
