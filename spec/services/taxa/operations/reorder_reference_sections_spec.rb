# frozen_string_literal: true

require 'rails_helper'

describe Taxa::Operations::ReorderReferenceSections do
  describe "#call" do
    let(:taxon) { create :any_taxon }
    let(:original_order) { item_ids taxon }
    let!(:first) { taxon.reference_sections.create! }
    let!(:second) { taxon.reference_sections.create! }
    let!(:third) { taxon.reference_sections.create! }

    def item_ids taxon
      taxon.reference_sections.pluck(:id)
    end

    context "when valid and different" do
      let(:reordered_ids) { [second.id, third.id, first.id] }

      it 'returns true' do
        expect(described_class[taxon, reordered_ids]).to eq true
      end

      it "updates the positions" do
        expect { described_class[taxon, reordered_ids] }.
          to change { item_ids(taxon) }.from(original_order).to(reordered_ids)
      end
    end

    context "when valid but not different" do
      let(:reordered_ids) { [first.id, second.id, third.id] }

      it "doesn't update the positions" do
        expect { described_class[taxon, reordered_ids] }.
          to_not change { item_ids(taxon) }.from(original_order)
      end

      it 'adds an error to the taxon' do
        expect(described_class[taxon, reordered_ids]).to eq false
        expect(taxon.errors.messages[:reference_sections]).to include(/already ordered like this/)
      end
    end

    context "when reordered ids are invalid" do
      let(:reordered_ids) { [second.id, third.id, 9999999] }

      it "doesn't update the positions" do
        expect { described_class[taxon, reordered_ids] }.
          to_not change { item_ids(taxon) }.from(original_order)
      end

      it 'adds an error to the taxon' do
        expect(described_class[taxon, reordered_ids]).to eq false
        expect(taxon.errors.messages[:reference_sections]).to include(/doesn't match current IDs/)
      end
    end
  end
end
