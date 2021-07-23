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

  describe 'POST start', as: :editor do
    let(:reference) { create :any_reference, review_state: Reference::REVIEW_STATE_NONE }

    specify do
      expect { post :start, params: { id: reference.id } }.
        to change { reference.reload.review_state }.to(Reference::REVIEW_STATE_REVIEWING)
    end
  end

  describe 'POST finish', as: :editor do
    let(:reference) { create :any_reference, review_state: Reference::REVIEW_STATE_REVIEWING }

    specify do
      expect { post :finish, params: { id: reference.id } }.
        to change { reference.reload.review_state }.to(Reference::REVIEW_STATE_REVIEWED)
    end
  end

  describe 'POST restart', as: :editor do
    let(:reference) { create :any_reference, review_state: Reference::REVIEW_STATE_REVIEWED }

    specify do
      expect { post :restart, params: { id: reference.id } }.
        to change { reference.reload.review_state }.to(Reference::REVIEW_STATE_REVIEWING)
    end
  end

  describe 'PUT approve_all', as: :current_user do
    let(:current_user) { create(:user, :superadmin, :editor) }

    before do
      create :any_reference, review_state: Reference::REVIEW_STATE_NONE
    end

    it 'approves all references' do
      expect { put :approve_all }.to change { Reference.unreviewed.count }.from(1).to(0)
    end

    it 'creates an activity' do
      expect { put :approve_all }.to change { Activity.count }.by(1)

      activity = Activity.last
      expect(activity.action).to eq Activity::APPROVE_ALL_REFERENCES
      expect(activity.parameters).to eq(count: 1)
    end
  end
end
