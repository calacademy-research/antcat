# frozen_string_literal: true

require 'rails_helper'

describe FeedbacksController do
  describe "forbidden actions" do
    context "when signed in as a user", as: :user do
      specify { expect(get(:show, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(get(:index)).to have_http_status :forbidden }
      specify { expect(get(:edit, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(post(:update, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(delete(:destroy, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(delete(:reopen, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(delete(:close, params: { id: 1 })).to have_http_status :forbidden }
    end

    context "when signed in as an editor", as: :editor do
      specify { expect(delete(:destroy, params: { id: 1 })).to have_http_status :forbidden }
    end
  end

  describe "GET index", as: :helper do
    specify { expect(get(:index)).to render_template :index }
  end

  describe "GET show", as: :helper do
    let!(:feedback) { create :feedback }

    specify { expect(get(:show, params: { id: feedback.id })).to render_template :show }
  end

  describe "GET new", as: :visitor do
    specify { expect(get(:new)).to render_template :new }
  end

  describe "POST create", as: :visitor do
    let(:valid_params) do
      { feedback: { comment: "Cool site", name: "Batiatus" } }
    end

    context "when feedback is valid" do
      it "creates a feedback item" do
        expect { post :create, params: valid_params }.to change { Feedback.count }.from(0).to(1)
      end
    end

    context "when a feedback with the same comment already exists" do
      before { post :create, params: valid_params }

      it "does not create a feedback item" do
        expect { post :create, params: valid_params }.to_not change { Feedback.count }.from(1)
      end

      it "includes a friendly error message in the response" do
        post :create, params: valid_params
        expect(assigns(:feedback).errors.full_messages.to_sentence).to include "Comment has already been submitted."
      end
    end
  end

  describe "GET edit", as: :helper do
    let!(:feedback) { create :feedback }

    specify { expect(get(:edit, params: { id: feedback.id })).to render_template :edit }
  end

  describe "PUT update", as: :helper do
    let!(:feedback) { create :feedback }
    let!(:feedback_params) do
      {
        comment: 'comment body',
        page: 'referenes'
      }
    end

    it 'updates the feedback' do
      put(:update, params: { id: feedback.id, feedback: feedback_params })

      feedback.reload
      expect(feedback.comment).to eq feedback_params[:comment]
      expect(feedback.page).to eq feedback_params[:page]
    end

    it 'creates an activity' do
      expect { put(:update, params: { id: feedback.id, feedback: feedback_params, edit_summary: 'summary' }) }.
        to change { Activity.where(action: :update).count }.by(1)

      activity = Activity.last
      feedback = Feedback.last
      expect(activity.trackable).to eq feedback
      expect(activity.edit_summary).to eq "summary"
    end
  end

  describe "DELETE destroy", as: :current_user do
    let(:current_user) { create(:user, :superadmin, :helper) }
    let!(:feedback) { create :feedback }

    it 'deletes the feedback' do
      expect { delete(:destroy, params: { id: feedback.id }) }.to change { Feedback.count }.by(-1)
    end

    it 'creates an activity' do
      expect { delete(:destroy, params: { id: feedback.id }) }.
        to change { Activity.where(action: :destroy, trackable: feedback).count }.by(1)
    end
  end
end
