require 'rails_helper'

describe TestOperations::BangSaveJournal do
  let!(:journal) { create :journal }

  describe "unsuccessful case" do
    subject(:operation) { described_class.new(journal, '') }

    context 'when not run in a transaction' do
      specify do
        expect { operation.run }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'when run in a transaction' do
      before do
        operation.extend RunInTransaction
      end

      it_behaves_like "an unsuccessful save journal operation" do
        let(:records_to_not_update) { [journal] }
      end
    end
  end

  describe "successful case" do
    subject(:operation) { described_class.new(journal, 'Jonkerz Quarterly') }

    it_behaves_like "a successful save journal operation" do
      let(:records_to_update) { [journal] }
    end
  end
end
