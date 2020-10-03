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

    it "renders the index view" do
      get :show, params: { id: activity.id }
      expect(response).to render_template :index
    end
  end

  describe "DELETE destroy", as: :superadmin do
    let!(:activity) { create :activity }

    it 'deletes the activity' do
      expect { delete(:destroy, params: { id: activity.id }) }.to change { Activity.count }.by(-1)
    end
  end
end
