require 'rails_helper'

describe Operations::ConvertToObsoleteCombination do
  subject(:operation) do
    described_class.new(
      current_valid_taxon: current_valid_taxon,
      new_combination: new_combination
    )
  end

  describe "#run" do
    describe "unsuccessful case" do
      context "when a species with this name already exists" do
        let!(:current_valid_taxon) do
          create :species, name_string: 'Oecodoma mexicana', genus: create(:genus, name_string: 'Oecodoma')
        end
        let!(:new_combination) { nil }

        specify { expect(operation.run).to be_a_failure }

        it "returns errors" do
          expect(operation.run.context.errors).to eq ["Current valid name must be set for obsolete combinations"]
        end

        it "does not modify the original species record" do
          expect { operation.run }.to_not change { current_valid_taxon.reload.attributes }
        end
      end
    end

    describe "successful case" do
      context "when there is no name collision" do
        let!(:current_valid_taxon) do
          create :species, name_string: 'Oecodoma mexicana', genus: create(:genus, name_string: 'Oecodoma')
        end
        let!(:new_combination) { create :species, name_string: 'Atta mexicana' }

        specify { expect(operation.run).to be_a_success }

        it "sets the status to obsolete combination" do
          expect { operation.run }.
            to change { current_valid_taxon.reload.status }.
            from(Status::VALID).to(Status::OBSOLETE_COMBINATION)
        end

        it "sets the current_valid_taxon" do
          expect { operation.run }.
            to change { current_valid_taxon.reload.current_valid_taxon }.
            from(nil).to(new_combination)
        end
      end
    end
  end
end
