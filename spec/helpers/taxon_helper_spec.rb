require 'rails_helper'

describe TaxonHelper do
  describe "#taxon_change_history" do
    let(:taxon) { create :family }
    let(:adder) { create :user }

    it "shows nothing for old taxa" do
      expect(helper.taxon_change_history(taxon)).to eq nil
    end

    it "shows the adder for waiting taxa" do
      change = create :change, taxon: taxon, change_type: "create", user: adder
      create :version, item: taxon, whodunnit: adder.id, change: change

      change_history = helper.taxon_change_history taxon
      expect(change_history).to match /Added by/
      expect(change_history).to match /#{adder.name}/
      expect(change_history).to match /less than a minute ago/
    end

    it "shows the adder and the approver for approved taxa" do
      approver = create :user

      change = create :change, taxon: taxon, change_type: "create", user: adder
      create :version, item: taxon, whodunnit: adder.id, change: change

      change = Change.find taxon.last_change.id
      change.update!(approver: approver, approved_at: Time.current)
      taxon.approve!

      change_history = helper.taxon_change_history taxon
      expect(change_history).to match /Added by/
      expect(change_history).to match /#{adder.name}/
      expect(change_history).to match /less than a minute ago/
      expect(change_history).to match /approved by/
      expect(change_history).to match /#{approver.name}/
      expect(change_history).to match /less than a minute ago/
    end
  end
end
