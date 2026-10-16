# frozen_string_literal: true

require 'rails_helper'

describe CommentsController do
  describe "COMMENTABLE_TYPES" do
    it "only contains commentable models" do
      expect(described_class::COMMENTABLE_TYPES.map(&:constantize)).to all(satisfy { |klass| klass < Commentable })
    end
  end

  describe "forbidden actions" do
    context "when not signed in", as: :visitor do
      specify { expect(get(:index)).to redirect_to_signin_form }
      specify { expect(get(:edit, params: { id: 1 })).to redirect_to_signin_form }
      specify { expect(post(:create)).to redirect_to_signin_form }
      specify { expect(put(:update, params: { id: 1 })).to redirect_to_signin_form }
    end
  end

  describe "POST create", as: :current_user do
    let(:current_user) { create :user }
    let!(:commentable) { create :site_notice }
    let!(:comment_params) do
      {
        commentable_type: commentable.class.name,
        commentable_id: commentable.id,
        body: 'Let me check.'
      }
    end

    it 'creates a comment' do
      expect { post(:create, params: { comment: comment_params }) }.to change { Comment.count }.by(1)

      comment = Comment.last
      expect(comment.body).to eq comment_params[:body]
      expect(comment.user).to eq current_user
    end

    it 'creates an activity' do
      expect { post(:create, params: { comment: comment_params }) }.
        to change { Activity.where(event: Activity::CREATE).count }.by(1)

      activity = Activity.last
      comment = Comment.last
      expect(activity.trackable).to eq comment
    end

    it 'redirects back to the referer, highlighting the comment' do
      request.env["HTTP_REFERER"] = "http://test.host/site_notices/#{commentable.id}#comment-0"
      post(:create, params: { comment: comment_params })

      expect(response).to redirect_to "http://test.host/site_notices/#{commentable.id}#comment-#{Comment.last.id}"
    end

    it 'redirects to the commentable when there is no referer' do
      post(:create, params: { comment: comment_params })

      expect(response).to redirect_to "http://test.host/site_notices/#{commentable.id}#comment-#{Comment.last.id}"
    end

    context 'when commentable type is not commentable' do
      it 'does not create a comment' do
        params = { comment: comment_params.merge(commentable_type: 'User', commentable_id: current_user.id) }

        expect { post(:create, params: params) }.to raise_error(ActiveRecord::RecordNotFound)
        expect(Comment.count).to eq 0
      end

      it 'does not constantize arbitrary class names' do
        params = { comment: comment_params.merge(commentable_type: 'Kernel') }

        expect { post(:create, params: params) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'PUT update', as: :current_user do
    let!(:comment) { create :comment }
    let(:current_user) { comment.user }
    let!(:comment_params) do
      {
        body: 'Let me check. Edit: looks OK.'
      }
    end

    it 'updates the comment' do
      expect(comment.edited?).to eq false

      put(:update, params: { id: comment.id, comment: comment_params })

      comment.reload
      expect(comment.body).to eq comment_params[:body]
      expect(comment.edited?).to eq true
    end

    context 'when comment does not belong to user', as: :editor do
      it 'does not update the comment' do
        expect { post :update, params: { id: comment.id } }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
