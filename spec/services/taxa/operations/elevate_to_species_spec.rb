# frozen_string_literal: true

require 'rails_helper'

describe Taxa::Operations::ElevateToSpecies do
  describe "#call" do
    describe "unuccessfully elevating" do
      context "when a species with this name already exists" do
        let!(:genus) { create :genus, name_string: 'Atta' }
        let!(:species) { create :species, name_string: 'Atta major', genus: genus }
        let!(:subspecies) { create :subspecies, name_string: 'Atta batta major', species: species }

        it "returns the new new non-persisted species with errors" do
          new_species = described_class[subspecies]
          expect(new_species.errors[:base]).to eq ["This name is in use by another taxon"]
        end

        it "does not create a new taxon" do
          expect { described_class[subspecies] }.to_not change { Taxon.count }
        end
      end
    end

    describe "successfully elevating" do
      context "when there is no name collision" do
        let!(:subspecies) { create :subspecies, subfamily: create(:subfamily) }

        it "does not modify the original subspecies record" do
          expect { described_class[subspecies] }.to_not change { subspecies.reload.attributes }
        end

        it "creates a new species" do
          expect { described_class[subspecies] }.to change { Species.count }.by(1)
        end

        it "returns the new species" do
          expect(described_class[subspecies]).to be_a Species
        end

        it "copies relevant attributes from the original subspecies record" do
          new_species = described_class[subspecies]

          [
            :fossil,
            :status,
            :homonym_replaced_by_id,
            :incertae_sedis_in,
            :protonym,
            :hong,
            :unresolved_homonym,
            :current_taxon
          ].each do |attribute|
            expect(new_species.public_send(attribute)).to eq subspecies.public_send(attribute)
          end
        end

        it "sets relevant taxonomical relations from the original subspecies" do
          new_species = described_class[subspecies]

          expect(new_species.subfamily).to eq subspecies.subfamily
          expect(new_species.subfamily).to be_a Subfamily

          expect(new_species.genus).to eq subspecies.genus
          expect(new_species.genus).to be_a Genus
        end

        it "nilifies `species_id`" do
          expect(described_class[subspecies].species_id).to eq nil
        end
      end

      describe "new name" do
        let!(:genus) { create :genus, name_string: 'Atta' }
        let!(:species) { create :species, name_string: 'Atta major', genus: genus }
        let!(:taxon) { create :subspecies, name_string: 'Atta major colobopsis', genus: genus, species: species }

        it "forms the new species name from the epithet" do
          new_species = described_class[taxon]

          expect(new_species.name.name).to eq 'Atta colobopsis'
          expect(new_species.name.epithet).to eq 'colobopsis'
        end
      end
    end
  end
end
