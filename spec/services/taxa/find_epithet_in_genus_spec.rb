require 'rails_helper'

describe Taxa::FindEpithetInGenus do
  describe "#call" do
    let!(:species) { create :species, name_string: 'Atta serratula' }

    context "when nothing matches" do
      specify { expect(described_class[species.genus, 'sdfsdf']).to eq [] }
    end

    it "returns matches" do
      expect(described_class[species.genus, 'serratula']).to eq [species]
    end

    describe "mandatory spelling changes" do
      it "finds -a when asked to find -us" do
        expect(described_class[species.genus, 'serratulus']).to eq [species]
      end
    end
  end
end
