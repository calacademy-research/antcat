require 'spec_helper'

describe AuthorNamesController do
  describe "forbidden actions" do
    context "when signed in as a helper" do
      before { sign_in create(:user, :helper) }

      specify { expect(get(:new, params: { author_id: 1 })).to have_http_status :forbidden }
      specify { expect(get(:edit, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(post(:create, params: { author_id: 1 })).to have_http_status :forbidden }
      specify { expect(put(:update, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(delete(:destroy, params: { id: 1 })).to have_http_status :forbidden }
    end
  end

  describe 'POST create' do
    let!(:author) { create :author }

    before { sign_in create(:user, :editor) }

    it 'creates an activity' do
      expect do
        post(:create, params: { author_name: { name: 'Batiatus' }, author_id: author.id, edit_summary: 'Add name' })
      end.to change { Activity.count }.by(1)

      activity = Activity.last
      expect(activity.action).to eq 'create'
      expect(activity.trackable).to be_a AuthorName
      expect(activity.edit_summary).to eq "Add name"
    end
  end

  describe 'PUT update' do
    let!(:author_name) { create :author_name }

    before { sign_in create(:user, :editor) }

    it 'creates an activity' do
      expect do
        put(:update, params: { author_name: { name: 'Batiatus' }, id: author_name.id, edit_summary: 'Edit name' })
      end.to change { Activity.count }.by(1)

      activity = Activity.last
      expect(activity.action).to eq 'update'
      expect(activity.trackable).to be_a AuthorName
      expect(activity.edit_summary).to eq "Edit name"
    end
  end

  describe 'DELETE destroy' do
    let!(:author) { create :author }
    let!(:author_name) { create :author_name, author: author }
    let!(:second_author_name) { create :author_name, author: author }

    before { sign_in create(:user, :editor, :superadmin) }

    it 'creates an activity' do
      expect { delete(:destroy, params: { id: author_name.id }) }.to change { Activity.count }.by(1)

      activity = Activity.last
      expect(activity.action).to eq 'destroy'
      expect(activity.trackable_type).to eq 'AuthorName'
      expect(activity.trackable_id).to eq author_name.id
    end
  end
end
