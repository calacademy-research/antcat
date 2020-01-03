require 'rails_helper'

describe CommentsController do
  describe "forbidden actions" do
    context "when not signed in" do
      specify { expect(get(:index)).to redirect_to_signin_form }
      specify { expect(get(:edit, params: { id: 1 })).to redirect_to_signin_form }
      specify { expect(post(:create)).to redirect_to_signin_form }
      specify { expect(put(:update, params: { id: 1 })).to redirect_to_signin_form }
    end
  end

  describe "POST create" do
    let!(:user) { create :user }
    let!(:commentable) { create :site_notice }
    let!(:comment_params) do
      {
        commentable_type: commentable.class.name,
        commentable_id: commentable.id,
        body: 'Let me check.'
      }
    end

    before { sign_in user }

    it 'creates a comment' do
      expect { post(:create, params: { comment: comment_params }) }.to change { Comment.count }.by(1)

      comment = Comment.last
      expect(comment.body).to eq comment_params[:body]
      expect(comment.user).to eq user
    end

    it 'creates an activity' do
      expect { post(:create, params: { comment: comment_params }) }.
        to change { Activity.where(action: :create).count }.by(1)

      activity = Activity.last
      comment = Comment.last
      expect(activity.trackable).to eq comment
    end
  end

  describe 'PUT update' do
    let!(:comment) { create :comment }
    let!(:comment_params) do
      {
        body: 'Let me check. Edit: looks OK.'
      }
    end

    before { sign_in comment.user }

    it 'updates the comment' do
      expect(comment.edited?).to eq false

      put(:update, params: { id: comment.id, comment: comment_params })

      comment.reload
      expect(comment.body).to eq comment_params[:body]
      expect(comment.edited?).to eq true
    end

    context 'when comment does not belong to user' do
      let!(:another_user) { create :user }

      before { sign_in another_user }

      it 'does not update the comment' do
        expect { post :update, params: { id: comment.id } }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
