require 'spec_helper'

describe TaxonHistoryItem do
  it { is_expected.to be_versioned }
  it { is_expected.to validate_presence_of :taxt }
  it { is_expected.to belong_to :taxon }

  describe "#update_taxt_from_editable" do
    let(:item) { create :taxon_history_item }

    context "when input is blank" do
      it "is invalid and has errors" do
        item.update_taxt_from_editable ''
        expect(item.errors).not_to be_empty
        expect(item.taxt).to be nil
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
      jumbled_id = TaxtIdTranslator.send :jumble_id, reference.id, 1
      other_jumbled_id = TaxtIdTranslator.send :jumble_id, other_reference.id, 1

      item.update_taxt_from_editable %{{Fisher, 1922 #{jumbled_id}}, also {Bolton, 1970 #{other_jumbled_id}}}
      expect(item.reload.taxt).to eq "{ref #{reference.id}}, also {ref #{other_reference.id}}"
    end

    context "when a reference isn't found" do
      it "adds an error" do
        expect { item.update_taxt_from_editable '{123}' }
          .to change { item.reload.errors.empty? }.from(true).to(false)
      end
    end
  end
end
