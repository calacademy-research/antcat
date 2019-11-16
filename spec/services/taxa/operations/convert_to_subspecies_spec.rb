require 'rails_helper'

describe Taxa::Operations::ConvertToSubspecies do
  describe "#call" do
    describe "unsuccessful conversion" do
      let!(:genus) { create :genus, name_string: 'Atta' }

      context "when species has subspecies" do
        let!(:species) { create :species }
        let!(:target_species_parent) { create :species }

        before do
          create :subspecies, species: species
        end

        specify do
          expect(described_class[species, target_species_parent]).to eq false
        end
      end

      context "when a subspecies with this name already exists" do
        let!(:species) { create :species, name_string: 'Camponotus dallatorrei', genus: genus }
        let!(:target_species_parent) { create :species, name_string: 'Camponotus alii', genus: genus }

        before { create :subspecies, name_string: 'Atta alii dallatorrei', genus: genus }

        it "does not create a new taxon" do
          expect { described_class[species, target_species_parent] }.to_not change { Taxon.count }
        end

        it "returns the new non-persisted subspecies with errors" do
          new_subspecies = described_class[species, target_species_parent]
          expect(new_subspecies.errors[:base]).to eq ["This name is in use by another taxon"]
        end
      end
    end

    describe "successful conversion" do
      context "when there is no name collision" do
        let!(:species) { create :species }
        let!(:target_species_parent) { create :species }

        it "does not modify the original species record" do
          expect { described_class[species, target_species_parent] }.to_not change { species.reload.attributes }
        end

        it "creates a new subspecies" do
          expect { described_class[species, target_species_parent] }.to change { Subspecies.count }.by(1)
        end

        it "returns the new subspecies" do
          expect(described_class[species, target_species_parent]).to be_a Subspecies
        end

        it "copies relevant attributes from the original species record" do
          new_subspecies = described_class[species, target_species_parent]

          [
            :fossil,
            :status,
            :homonym_replaced_by_id,
            :incertae_sedis_in,
            :protonym,
            :type_taxt,
            :headline_notes_taxt,
            :hong,
            :unresolved_homonym,
            :current_valid_taxon,
            :ichnotaxon,
            :nomen_nudum,
            :type_taxon
          ].each do |attribute|
            expect(new_subspecies.public_send(attribute)).to eq species.public_send(attribute)
          end
        end

        it "sets relevant taxonomical relations from the target species" do
          new_subspecies = described_class[species, target_species_parent]

          expect(new_subspecies.subfamily).to eq target_species_parent.subfamily
          expect(new_subspecies.genus).to eq target_species_parent.genus
          expect(new_subspecies.species).to eq target_species_parent
        end

        context "when taxon belongs to a subgenus" do
          let!(:species) { create :species, subgenus: create(:subgenus) }

          it "nilifies `subgenus_id`" do
            expect(described_class[species, target_species_parent].subgenus_id).to eq nil
          end
        end

        context "when taxon has history items" do
          let!(:history_item) { create :taxon_history_item, taxon: species }

          it 'moves them to the new subspecies' do
            expect(history_item.taxon).to eq species
            new_subspecies = described_class[species, target_species_parent]
            expect(history_item.reload.taxon).to eq new_subspecies
          end
        end
      end
    end
  end
end
