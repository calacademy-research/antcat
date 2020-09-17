# frozen_string_literal: true

# TODO: These specs are overly verbose. To be tweaked after testing `Operation`s more.

require 'rails_helper'

describe Operations::CreateNewCombination do
  subject(:operation) do
    described_class.new(
      current_taxon: current_taxon,
      new_genus: new_genus,
      target_name_string: target_name_string
    )
  end

  before do
    operation.extend RunInTransaction
  end

  describe "#run" do
    describe "unsuccessful case" do
      let!(:current_taxon) do
        create :species, name_string: 'Oecodoma mexicana', genus: create(:genus, name_string: 'Oecodoma')
      end
      let!(:new_genus) { create :genus, name_string: 'Atta' }
      let!(:target_name_string) { 'Atta mexicana' }

      let!(:history_item) { create :taxon_history_item, taxon: current_taxon }

      # Make sure specs pass with the above setup.
      specify { expect(operation.run).to be_a_success }

      context "when a species with this name already exists" do
        before do
          create :species, name_string: 'Atta mexicana'
        end

        specify { expect(operation.run).to be_a_failure }

        it "returns errors" do
          expect(operation.run.context.errors).to eq ["Atta mexicana - This name is in use by another taxon"]
        end

        it "does not create a new taxon" do
          expect { operation.run }.to_not change { Taxon.count }
        end

        it "does not modify the original species record" do
          expect { operation.run }.to_not change { current_taxon.reload.attributes }
        end
      end

      context "when moving history items fails" do
        before do
          history_item.update_columns(taxt: '')
        end

        specify { expect(operation.run).to be_a_failure }

        it "does not create a new taxon" do
          expect { operation.run }.to_not change { Taxon.count }
        end

        it 'does not move any history items' do
          expect(history_item.reload.valid?).to eq false
          expect { operation.run }.to_not change { history_item.reload.taxon }.from(current_taxon)
        end

        it "does not modify the original species record" do
          expect { operation.run }.to_not change { current_taxon.reload.attributes }
        end
      end

      context "when updating the now obsolete combination fails" do
        before do
          current_taxon.update_columns(homonym_replaced_by_id: Taxon.first.id)
        end

        specify { expect(operation.run).to be_a_failure }

        it "returns errors" do
          expect(operation.run.context.errors).to eq ["Homonym replaced by can't be set for non-homonyms"]
        end

        it "does not create a new taxon" do
          expect { operation.run }.to_not change { Taxon.count }
        end

        it 'does not move any history items' do
          expect { operation.run }.
            to_not change { history_item.reload.taxon }.from(current_taxon)
        end

        it "does not modify the original species record" do
          expect { operation.run }.to_not change { current_taxon.reload.attributes }
        end
      end

      context 'when taxon has obsolete combinations which cannot be updated' do
        let!(:obsolete_combination_1) do
          create :species, status: Status::OBSOLETE_COMBINATION, current_taxon: current_taxon,
            protonym: current_taxon.protonym
        end
        let!(:obsolete_combination_2) do
          create :species, status: Status::OBSOLETE_COMBINATION, current_taxon: current_taxon,
            protonym: current_taxon.protonym
        end

        before do
          obsolete_combination_2.update_columns(ichnotaxon: true) # Invalid state to prevent saving.
        end

        specify { expect(operation.run).to be_a_failure }

        it "returns errors" do
          expect(operation.run.context.errors).to eq ["Ichnotaxon can only be set for fossil taxa"]
        end

        it "does not create a new taxon" do
          expect { operation.run }.to_not change { Taxon.count }
        end

        it 'does not move any history items' do
          expect { operation.run }.
            to_not change { history_item.reload.taxon }.from(current_taxon)
        end

        it "does not modify the original species record" do
          expect { operation.run }.to_not change { current_taxon.reload.attributes }
        end

        it 'does not update the `current_taxon` of the obsolete combinations' do
          expect(current_taxon.obsolete_combinations).to match_array [obsolete_combination_1, obsolete_combination_2]

          expect { operation.run }.
            to_not change { obsolete_combination_1.reload.current_taxon }.
            from(current_taxon)

          expect(current_taxon.obsolete_combinations).to match_array [obsolete_combination_1, obsolete_combination_2]
        end
      end
    end

    describe "successful case" do
      context "when there is no name collision" do
        let!(:current_taxon) do
          create :species, name_string: 'Oecodoma mexicana', genus: create(:genus, name_string: 'Oecodoma')
        end
        let!(:new_genus) { create :genus, name_string: 'Atta' }
        let!(:target_name_string) { 'Atta mexicana' }

        specify { expect(operation.run).to be_a_success }

        it "does not modify unrelated attributes of `current_taxon`" do
          expect { operation.run }.
            to_not change { current_taxon.reload.attributes.except('status', 'current_taxon_id', 'updated_at') }
        end

        it "converts the existing taxon to an obsolete combination" do
          expect(current_taxon.status).to eq Status::VALID
          expect(current_taxon.current_taxon).to eq nil

          results = operation.run.results

          expect(current_taxon.current_taxon).to eq results.new_combination
          expect(current_taxon.status).to eq Status::OBSOLETE_COMBINATION
        end

        it "creates a new taxon" do
          expect { operation.run }.to change { Taxon.count }.by(1)
        end

        it "returns the new taxon" do
          expect(operation.run.results.new_combination).to be_a Species
        end

        it "creates a new species name with the correct name parts" do
          results = operation.run.results
          expect(results.new_combination.name).to be_a SpeciesName
          expect(results.new_combination.name.name).to eq target_name_string
        end

        describe "moving history items" do
          let!(:history_item) { create :taxon_history_item, taxon: current_taxon }

          it 'moves history items to the new combination' do
            expect(history_item.reload.taxon).to eq current_taxon
            new_combination = operation.run.results.new_combination
            expect(history_item.reload.taxon).to eq new_combination
          end
        end
      end
    end
  end
end
