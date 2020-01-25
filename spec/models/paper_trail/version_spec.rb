require 'rails_helper'

describe PaperTrail::Version do
  it_behaves_like "a model that assigns `request_id` on create" do
    let!(:item) { create :user }
    let(:instance) { build :version, item: item }
  end

  describe "#user" do
    context 'when version has a whodunnit' do
      let!(:user) { create :user }
      let!(:version) { build_stubbed :version, whodunnit: user.id }

      specify { expect(version.user).to eq user }
    end

    context 'when version does not have a whodunnit' do
      let!(:version) { build_stubbed :version, whodunnit: nil }

      specify { expect(version.user).to eq nil }
    end
  end
end
