require 'spec_helper'

describe Protonym do
  it { is_expected.to be_versioned }
  it { is_expected.to validate_presence_of :authorship }

  # TODO see model.
  xdescribe "#destroy" do
    describe "Cascading delete" do
      let!(:protonym) { create :protonym }

      it "deletes the citation when the protonym is deleted" do
        expect(described_class.count).to eq 1
        expect(Citation.count).to eq 1

        protonym.destroy

        expect(described_class.count).to be_zero
        expect(Citation.count).to be_zero
      end
    end
  end
end
