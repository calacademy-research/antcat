require 'spec_helper'

describe Change do
  describe "validations" do
    it { is_expected.to validate_presence_of(:user).on(:create) }
  end

  describe "scopes" do
    let(:user) { create :user }

    describe ".waiting" do
      before do
        taxon_1 = create :family
        taxon_1.taxon_state.update review_state: TaxonState::WAITING
        @unreviewed_change = setup_version taxon_1, user

        taxon_2 = create :family
        taxon_2.taxon_state.update review_state: TaxonState::APPROVED
        approved_earlier_change = setup_version taxon_2, user
        approved_earlier_change.update approved_at: 7.days.ago

        taxon_2 = create :family
        taxon_2.taxon_state.update review_state: TaxonState::APPROVED
        approved_later_change = setup_version taxon_2, user
        approved_later_change.update approved_at: 7.days.from_now
      end

      it "returns unreviewed changes" do
        expect(described_class.waiting).to eq [@unreviewed_change]
      end
    end
  end
end
