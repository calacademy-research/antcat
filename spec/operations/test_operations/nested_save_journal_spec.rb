require 'rails_helper'

describe TestOperations::NestedSaveJournal do
  subject(:operation) { described_class.new(journal_1, new_name_1, journal_2, new_name_2) }

  let!(:journal_1) { create :journal }
  let!(:journal_2) { create :journal }

  describe "unsuccessful case" do
    context 'when the first operation fails' do
      let(:new_name_1) { '' }
      let(:new_name_2) { 'Jonkerz Monthly' }

      it_behaves_like "an unsuccessful save journal operation" do
        let(:records_to_not_update) { [journal_1, journal_2] }
      end
    end

    context 'when the second operation fails' do
      let(:new_name_1) { 'Jonkerz Quarterly' }
      let(:new_name_2) { '' }

      context 'when not run in a transaction' do
        it_behaves_like "an unsuccessful save journal operation"

        it "updates the first record" do
          expect { operation.run }.to change { journal_1.reload.name }
        end

        it "does not update the second record" do
          expect { operation.run }.to_not change { journal_2.reload.name }
        end
      end

      context 'when run in a transaction' do
        before do
          operation.extend RunInTransaction
        end

        it_behaves_like "an unsuccessful save journal operation" do
          let(:records_to_not_update) { [journal_1, journal_2] }
        end
      end
    end

    context 'when the first and second operations fail' do
      let(:new_name_1) { '' }
      let(:new_name_2) { '' }

      it_behaves_like "an unsuccessful save journal operation" do
        let(:records_to_not_update) { [journal_1, journal_2] }
      end
    end
  end

  describe "successful case" do
    let(:new_name_1) { 'Jonkerz Quarterly' }
    let(:new_name_2) { 'Jonkerz Monthly' }

    it_behaves_like "a successful save journal operation" do
      let(:records_to_update) { [journal_1, journal_2] }
    end
  end
end
