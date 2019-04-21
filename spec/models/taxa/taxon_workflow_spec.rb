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
