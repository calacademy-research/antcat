require 'spec_helper'

describe Taxa::ForceParentChange do
  describe "#call" do
    context "when there is no name collision" do
      let!(:species) { create :species }
      let!(:subspecies) { create :subspecies, species: species }
      let!(:new_parent) { create :species }

      it "updates the parent of the taxon" do
        expect { described_class[subspecies, new_parent] }.
          to change { subspecies.reload.species }.from(species).to(new_parent)
      end
    end
  end
end
