require 'rails_helper'

describe Operations::CreateNewCombinationRecord do
  subject(:operation) do
    described_class.new(
      current_valid_taxon: current_valid_taxon,
      new_genus: new_genus,
      target_name_string: target_name_string
    )
  end

  describe "#run" do
    describe "unsuccessful case" do
      context "when a species with this name already exists" do
        let!(:current_valid_taxon) do
          create :species, name_string: 'Oecodoma mexicana', genus: create(:genus, name_string: 'Oecodoma')
        end
        let!(:new_genus) { create :genus, name_string: 'Atta' }
        let!(:target_name_string) { 'Atta mexicana' }

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
      end
    end

    describe "successful case" do
      context "when there is no name collision" do
        let!(:current_valid_taxon) do
          create :species, name_string: 'Oecodoma mexicana', genus: create(:genus, name_string: 'Oecodoma')
        end
        let!(:new_genus) { create :genus, name_string: 'Atta' }
        let!(:target_name_string) { 'Atta mexicana' }

        specify { expect(operation.run).to be_a_success }

        it "creates a new taxon" do
          expect { operation.run }.to change { Taxon.count }.by(1)
        end

        it "returns the new species" do
          expect(operation.run.results.new_combination).to be_a Species
        end

        it "creates a new species name with the correct name parts" do
          results = operation.run.results
          expect(results.new_combination.name).to be_a SpeciesName
          expect(results.new_combination.name.name).to eq target_name_string
        end

        it "sets the status to valid" do
          expect(operation.run.results.new_combination.status).to eq Status::VALID
        end

        it "sets the protonym to the current valid taxon's protonym" do
          expect(operation.run.results.new_combination.protonym).to eq current_valid_taxon.protonym
        end

        it "sets the parent genus to the new genus" do
          expect(operation.run.results.new_combination.genus).to eq new_genus
        end
      end
    end
  end
end
