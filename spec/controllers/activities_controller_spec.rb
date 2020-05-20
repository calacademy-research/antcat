# frozen_string_literal: true

require 'rails_helper'

describe ActivitiesController do
  describe "forbidden actions" do
    context "when signed in as a user", as: :user do
      specify { expect(delete(:destroy, params: { id: 1 })).to have_http_status :forbidden }
    end

    context "when signed in as an editor", as: :editor do
      specify { expect(delete(:destroy, params: { id: 1 })).to have_http_status :forbidden }
    end
  end

  describe "GET show", as: :visitor do
    let!(:activity) { create :activity }

    it "redirects to the index" do
      get :show, params: { id: activity.id }
      expect(response).to redirect_to activities_path(id: activity.id.to_s, page: '1', anchor: "activity-#{activity.id}")
    end
  end

  describe "DELETE destroy", as: :superadmin do
    let!(:activity) { create :activity }

    it 'deletes the activity' do
      expect { delete(:destroy, params: { id: activity.id }) }.to change { Activity.count }.by(-1)
    end
  end
end
