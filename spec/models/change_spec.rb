require 'spec_helper'

describe Change do
  describe "validations" do
    it { is_expected.to validate_presence_of(:user).on(:create) }
  end

  describe "scopes" do
    describe ".waiting" do
      let!(:unreviewed_change) { create :change, taxon: create(:family, :waiting) }

      before do
        create :change, taxon: create(:family, :old)
      end

      it "returns unreviewed changes" do
        expect(described_class.waiting).to eq [unreviewed_change]
      end
    end
  end
end
