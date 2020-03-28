# frozen_string_literal: true

require 'rails_helper'

describe References::ReviewsController do
  describe "forbidden actions" do
    context "when signed in as a user", as: :user do
      specify { expect(post(:start, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(post(:finish, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(post(:restart, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(post(:approve_all, params: { id: 1 })).to have_http_status :forbidden }
    end

    context "when signed in as an editor", as: :editor do
      specify { expect(post(:approve_all, params: { id: 1 })).to have_http_status :forbidden }
    end
  end

  describe 'PUT approve_all', as: :current_user do
    let(:current_user) { create(:user, :superadmin, :editor) }

    before do
      create :any_reference, review_state: 'none'
    end

    it 'approves all references' do
      expect { put :approve_all }.to change { Reference.unreviewed.count }.from(1).to(0)
    end

    it 'creates an activity' do
      expect {  put :approve_all }.to change { Activity.count }.by(1)

      activity = Activity.last
      expect(activity.action).to eq "approve_all_references"
      expect(activity.parameters).to eq(count: 1)
    end
  end
end
