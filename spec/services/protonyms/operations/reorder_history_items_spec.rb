# frozen_string_literal: true

require 'rails_helper'

describe Protonyms::Operations::ReorderHistoryItems do
  describe "#call" do
    let(:protonym) { create :protonym }
    let(:original_order) { item_ids protonym }
    let!(:first) { protonym.protonym_history_items.create!(taxt: "A") }
    let!(:second) { protonym.protonym_history_items.create!(taxt: "B") }
    let!(:third) { protonym.protonym_history_items.create!(taxt: "C") }

    before do
      protonym.reload
    end

    def item_ids protonym
      protonym.protonym_history_items.pluck(:id)
    end

    context "when valid and different" do
      let(:reordered_ids) { [second.id, third.id, first.id] }

      it 'returns true' do
        expect(described_class[protonym, reordered_ids]).to eq true
      end

      it "updates the positions" do
        expect { described_class[protonym, reordered_ids] }.
          to change { item_ids(protonym) }.from(original_order).to(reordered_ids)
      end

      context 'when a history item cannot be saved due to validations' do
        let(:reordered_ids) { [second.id, third.id, first.id] }

        before do
          third.update_columns(taxt: '')
        end

        it "doesn't update the positions" do
          expect(third.valid?).to eq false
          expect { described_class[protonym, reordered_ids] }.
            to_not change { item_ids(protonym) }.from(original_order)
        end

        it 'adds an error to the protonym' do
          expect(described_class[protonym, reordered_ids]).to eq false
          expect(protonym.errors.messages[:protonym_history_items]).to include(/are not valid, please fix them first/)
        end
      end
    end

    context "when valid but not different" do
      let(:reordered_ids) { [first.id, second.id, third.id] }

      it "doesn't update the positions" do
        expect { described_class[protonym, reordered_ids] }.
          to_not change { item_ids(protonym) }.from(original_order)
      end

      it 'adds an error to the protonym' do
        expect(described_class[protonym, reordered_ids]).to eq false
        expect(protonym.errors.messages[:protonym_history_items]).to include(/already ordered like this/)
      end
    end

    context "when reordered ids are invalid" do
      let(:reordered_ids) { [second.id, third.id, 9999999] }

      it "doesn't update the positions" do
        expect { described_class[protonym, reordered_ids] }.
          to_not change { item_ids(protonym) }.from(original_order)
      end

      it 'adds an error to the protonym' do
        expect(described_class[protonym, reordered_ids]).to eq false
        expect(protonym.errors.messages[:protonym_history_items]).to include(/doesn't match current IDs/)
      end
    end
  end
end
