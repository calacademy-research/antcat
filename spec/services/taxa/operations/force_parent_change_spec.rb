# frozen_string_literal: true

require 'rails_helper'

describe Taxa::Operations::ForceParentChange do
  describe "#call" do
    context "when there is no name collision" do
      let!(:old_species) { create :species }
      let!(:subspecies) { create :subspecies, species: old_species }
      let!(:new_parent) { create :species }

      it "updates the parent of the taxon" do
        expect { described_class[subspecies, new_parent] }.
          to change { subspecies.reload.species }.from(old_species).to(new_parent)
      end

      context "when the taxon cannot be saved" do
        let!(:species) { create :species, name_string: 'Atta major' }
        let!(:new_genus) { create :genus, name_string: 'Eciton' }

        before do
          allow(species).to receive(:save).and_return(false)
        end

        it "rolls back the name change too" do
          expect(described_class[species, new_genus]).to be_nil
          expect(species.name.reload.name).to eq 'Atta major'
          expect(Species.find(species.id).genus).not_to eq new_genus
        end
      end
    end

    context "when there is a name collision" do
      let!(:subspecies) { create :subspecies, name_string: 'Atta major minor' }
      let!(:new_parent) { create :species, name_string: 'Eciton niger' }

      before do
        create :subspecies, name_string: 'Eciton niger minor'
      end

      it "raises" do
        expect { described_class[subspecies, new_parent] }.to raise_error Taxa::TaxonExists
      end
    end
  end
end
