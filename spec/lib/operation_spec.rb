# frozen_string_literal: true

require 'rails_helper'
require_relative 'fixtures/test_operations/bang_save_journal'
require_relative 'fixtures/test_operations/nested_save_journal'
require_relative 'fixtures/test_operations/save_journal'

describe Operation do
  shared_examples_for "a successful save journal operation" do
    let(:records_to_update) { [] }

    specify { expect(operation.run).to be_a_success }
    specify { expect(operation.run.context.errors).to eq [] }

    it "updates the record(s)" do
      expect { operation.run }.to_not change { records_to_update.map { |record| record&.reload } }
    end
  end

  shared_examples_for "an unsuccessful save journal operation" do
    let(:records_to_not_update) { [] }

    specify { expect(operation.run).to be_a_failure }

    it "returns errors" do
      expect(operation.run.context.errors.to_s).to include "Name can't be blank"
    end

    it 'does not update the record(s)' do
      expect { operation.run }.to_not change { records_to_not_update.map { |record| record&.reload } }
    end
  end

  describe '#run' do
    context 'when `#execute` is not implemented' do
      let(:dummy_class) { Class.new { include Operation } }

      specify { expect { dummy_class.new.run }.to raise_error(NotImplementedError) }
    end
  end

  describe 'delegation' do
    let(:dummy_class) { Class.new { include Operation } }
    let(:dummy) { dummy_class.new }

    it { expect(dummy).to delegate_method(:success?).to(:context) }
    it { expect(dummy).to delegate_method(:failure?).to(:context) }
  end

  describe TestOperations::SaveJournal do
    let!(:journal) { create :journal }

    describe "unsuccessful case" do
      subject(:operation) { described_class.new(journal, '') }

      it_behaves_like "an unsuccessful save journal operation" do
        let(:records_to_not_update) { [journal] }
      end
    end

    describe "successful case" do
      subject(:operation) { described_class.new(journal, 'Jonkerz Quarterly') }

      it_behaves_like "a successful save journal operation" do
        let(:records_to_update) { [journal] }
      end
    end

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
  end
end
