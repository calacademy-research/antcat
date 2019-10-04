require "spec_helper"

describe Taxa::Operations::ReorderHistoryItems do
  describe "#call" do
    let(:taxon) { create :family }
    let(:original_order) { item_ids taxon }
    let!(:first) { taxon.history_items.create!(taxt: "A") }
    let!(:second) { taxon.history_items.create!(taxt: "B") }
    let!(:third) { taxon.history_items.create!(taxt: "C") }

    def item_ids taxon
      taxon.history_items.pluck(:id)
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

      context 'when a history item cannot be saved due to validations' do
        let(:reordered_ids) { [second.id, third.id, first.id] }

        before do
          third.update_columns(taxt: '') # rubocop:disable Rails/SkipsModelValidations
        end

        it "doesn't update the positions" do
          expect(third.valid?).to eq false
          expect { described_class[taxon, reordered_ids] }.
            to_not change { item_ids(taxon) }.from(original_order)
        end

        it 'adds an error to the taxon' do
          expect(described_class[taxon, reordered_ids]).to eq false
          expect(taxon.errors.messages[:history_items]).to include(/are not valid, please fix them first/)
        end
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
        expect(taxon.errors.messages[:history_items]).to include(/already ordered like this/)
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
        expect(taxon.errors.messages[:history_items]).to include(/doesn't match current IDs/)
      end
    end
  end
end
