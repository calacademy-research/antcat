# frozen_string_literal: true

require 'rails_helper'

describe Operations::ConvertToObsoleteCombination do
  subject(:operation) do
    described_class.new(
      current_taxon: current_taxon,
      new_combination: new_combination
    )
  end

  describe "#run" do
    describe "unsuccessful case" do
      context "when a species with this name already exists" do
        let!(:current_taxon) do
          create :species, name_string: 'Oecodoma mexicana', genus: create(:genus, name_string: 'Oecodoma')
        end
        let!(:new_combination) { nil }

        specify { expect(operation.run).to be_a_failure }

        it "returns errors" do
          expect(operation.run.context.errors).to eq ["Current valid name must be set for obsolete combinations"]
        end

        it "does not modify the original species record" do
          expect { operation.run }.to_not change { current_taxon.reload.attributes }
        end
      end

      context 'when run in a transaction' do
        before do
          operation.extend RunInTransaction
        end

        context 'when taxon has obsolete combinations which cannot be updated' do
          let!(:current_taxon) do
            create :species, name_string: 'Oecodoma mexicana', genus: create(:genus, name_string: 'Oecodoma')
          end
          let!(:new_combination) { create :species, name_string: 'Atta mexicana' }
          let!(:obsolete_combination_1) do
            create :species, status: Status::OBSOLETE_COMBINATION, current_taxon: current_taxon
          end
          let!(:obsolete_combination_2) do
            create :species, status: Status::OBSOLETE_COMBINATION, current_taxon: current_taxon
          end

          before do
            obsolete_combination_2.update_columns(nomen_nudum: true) # Invalid state to prevent saving.
          end

          it "does not modify the original species record" do
            expect { operation.run }.to_not change { current_taxon.reload.attributes }
          end

          it 'does not update the `current_taxon` of the obsolete combinations' do
            expect(current_taxon.obsolete_combinations).to eq [obsolete_combination_1, obsolete_combination_2]
            expect(new_combination.obsolete_combinations).to eq []

            expect { operation.run }.
              to_not change { obsolete_combination_1.reload.current_taxon }.
              from(current_taxon)

            expect(current_taxon.obsolete_combinations).to eq [obsolete_combination_1, obsolete_combination_2]
            expect(new_combination.obsolete_combinations).to eq []
          end
        end
      end
    end

    describe "successful case" do
      context "when there is no name collision" do
        let!(:current_taxon) do
          create :species, name_string: 'Oecodoma mexicana', genus: create(:genus, name_string: 'Oecodoma')
        end
        let!(:new_combination) { create :species, name_string: 'Atta mexicana' }

        specify { expect(operation.run).to be_a_success }

        it "sets the status to obsolete combination" do
          expect { operation.run }.
            to change { current_taxon.reload.status }.
            from(Status::VALID).to(Status::OBSOLETE_COMBINATION)
        end

        it "sets the current_taxon" do
          expect { operation.run }.
            to change { current_taxon.reload.current_taxon }.
            from(nil).to(new_combination)
        end
      end

      context 'when taxon has obsolete combinations' do
        let!(:current_taxon) do
          create :species, name_string: 'Oecodoma mexicana', genus: create(:genus, name_string: 'Oecodoma')
        end
        let!(:new_combination) { create :species, name_string: 'Atta mexicana' }
        let!(:obsolete_combination) do
          create :species, status: Status::OBSOLETE_COMBINATION, current_taxon: current_taxon
        end

        it 'updates the `current_taxon` of the obsolete combinations' do
          expect(current_taxon.obsolete_combinations).to eq [obsolete_combination]
          expect(new_combination.obsolete_combinations).to eq []

          expect { operation.run }.
            to change { obsolete_combination.reload.current_taxon }.
            from(current_taxon).to(new_combination)

          expect(current_taxon.obsolete_combinations).to eq [obsolete_combination]
          expect(new_combination.obsolete_combinations).to eq []
        end
      end
    end
  end
end
