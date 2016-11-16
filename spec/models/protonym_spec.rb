require 'spec_helper'

describe Protonym do
  it { should be_versioned }
  it { should validate_presence_of :authorship }

  describe "#destroy" do
    describe "Cascading delete" do
      it "deletes the citation when the protonym is deleted" do
        protonym = create :protonym

        expect(Protonym.count).to eq 1
        expect(Citation.count).to eq 1

        protonym.destroy
        expect(Protonym.count).to be_zero
        expect(Citation.count).to be_zero
      end
    end
  end
end
