require 'spec_helper'

describe References::ReviewsController do
  describe "forbidden actions" do
    context "when signed in as a user" do
      before { sign_in create(:user) }

      specify { expect(post(:start, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(post(:finish, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(post(:restart, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(post(:approve_all, params: { id: 1 })).to have_http_status :forbidden }
    end

    context "when signed in as an editor" do
      before { sign_in create(:user, :editor) }

      specify { expect(post(:approve_all, params: { id: 1 })).to have_http_status :forbidden }
    end
  end

  describe 'PUT approve_all' do
    before { sign_in create(:user, :superadmin, :editor) }

    let!(:reference) { create :article_reference, review_state: 'none' }

    it 'approves all references' do
      expect { put :approve_all }.to change { Reference.unreviewed.count }.from(1).to(0)
    end

    it 'creates an activity', :feed do
      expect {  put :approve_all }.to change { Activity.count }.by(1)

      activity = Activity.last
      expect(activity.action).to eq "approve_all_references"
      expect(activity.parameters).to eq(count: 1)
    end
  end
end
