require 'spec_helper'

describe TaxonHistoryItem do
  it { should be_versioned }
  it { should validate_presence_of :taxt }
  it { should belong_to :taxon }

  describe "#update_taxt_from_editable" do
    let(:item) { create :taxon_history_item }

    context "on blank input" do
      it "is invalid and has errors without blowing up" do
        item.update_taxt_from_editable ''
        expect(item.errors).not_to be_empty
        expect(item.taxt).to eq ''
        expect(item).not_to be_valid
      end
    end

    it "passes non-tags straight through" do
      item.update_taxt_from_editable 'abc'
      expect(item.reload.taxt).to eq 'abc'
    end

    it "converts from editable tags to tags" do
      reference = create :article_reference
      other_reference = create :article_reference
      editable_keey = TaxtConverter.send :id_for_editable, reference.id, 1
      other_editable_keey = TaxtConverter.send :id_for_editable, other_reference.id, 1

      item.update_taxt_from_editable %{{Fisher, 1922 #{editable_keey}}, also {Bolton, 1970 #{other_editable_keey}}}
      expect(item.reload.taxt).to eq "{ref #{reference.id}}, also {ref #{other_reference.id}}"
    end

    it "has errors if a reference isn't found" do
      expect(item.errors).to be_empty
      item.update_taxt_from_editable '{123}'
      expect(item.errors).not_to be_empty
    end
  end
end
