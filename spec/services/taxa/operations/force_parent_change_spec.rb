require 'spec_helper'

describe Taxa::Operations::ForceParentChange do
  before do
    fake_current_user
  end

  describe "#call" do
    context "when there is no name collision" do
      let!(:old_species) { create :species }
      let!(:subspecies) { create :subspecies, species: old_species }
      let!(:new_parent) { create :species }

      it "updates the parent of the taxon" do
        expect { described_class[subspecies, new_parent] }.
          to change { subspecies.reload.species }.from(old_species).to(new_parent)
      end

      it "creates a change" do
        expect { described_class[subspecies, new_parent] }.
          to change { Change.where(taxon: subspecies).count }.by(1)
      end
    end

    context "when there is a name collision" do
      let!(:subspecies) { create :subspecies, name_string: 'Atta major minor' }
      let!(:new_parent) { create :species, name_string: 'Eciton niger' }

      before do
        create :subspecies, name_string: 'Eciton niger minor'
      end

      it "raises" do
        expect { described_class[subspecies, new_parent] }.to raise_error Taxon::TaxonExists
      end

      it "does not create a change" do
        expect { described_class[subspecies, new_parent] rescue nil }.
          to_not change { Change.where(taxon: subspecies).count }
      end
    end
  end
end
