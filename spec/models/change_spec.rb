require 'spec_helper'

describe Change, versioning: true do
  let(:user) { create :user }

  describe 'relationships' do
    it "has a version" do
      genus = create_genus
      change = described_class.new user: user
      change.save!
      change.reload
      create :version, item: genus, change_id: change.id
      genus_version = genus.last_version

      expect(change.versions.first).to eq genus_version
    end

    it "has a user (the editor)" do
      # TODO
    end
  end

  describe "scopes" do
    describe ".waiting" do
      before do
        genus_1 = create_genus
        genus_1.taxon_state.update review_state: 'waiting'
        @unreviewed_change = setup_version genus_1, user

        genus_2 = create_genus
        genus_2.taxon_state.update review_state: 'approved'
        approved_earlier_change = setup_version genus_2, user
        approved_earlier_change.update approved_at: (Date.today - 7)

        genus_2 = create_genus
        genus_2.taxon_state.update review_state: 'approved'
        approved_later_change = setup_version genus_2, user
        approved_later_change.update approved_at: (Date.today + 7)
      end

      it "returns unreviewed changes" do
        expect(described_class.waiting).to eq [@unreviewed_change]
      end
    end
  end
end
