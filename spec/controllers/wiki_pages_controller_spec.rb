# frozen_string_literal: true

require 'rails_helper'

describe WikiPagesController do
  describe "forbidden actions" do
    context "when not signed in", as: :visitor do
      specify { expect(get(:new)).to redirect_to_signin_form }
      specify { expect(get(:edit, params: { id: 1 })).to redirect_to_signin_form }
      specify { expect(post(:create)).to redirect_to_signin_form }
      specify { expect(put(:update, params: { id: 1 })).to redirect_to_signin_form }
    end

    context "when signed in as an editor", as: :editor do
      specify { expect(delete(:destroy, params: { id: 1 })).to have_http_status :forbidden }
    end
  end

  describe "GET index", as: :visitor do
    specify { expect(get(:index)).to render_template :index }
  end

  describe "GET show", as: :user do
    let!(:wiki_page) { create :wiki_page }

    specify { expect(get(:show, params: { id: wiki_page.id })).to render_template :show }
  end

  describe "GET new", as: :user do
    specify { expect(get(:new)).to render_template :new }
  end

  describe "POST create", as: :user do
    let!(:wiki_page_params) do
      {
        title: 'Title',
        content: 'content'
      }
    end

    it 'creates a wiki page' do
      expect { post(:create, params: { wiki_page: wiki_page_params }) }.to change { WikiPage.count }.by(1)

      wiki_page = WikiPage.last
      expect(wiki_page.title).to eq wiki_page_params[:title]
      expect(wiki_page.content).to eq wiki_page_params[:content]
    end

    it 'creates an activity' do
      expect { post(:create, params: { wiki_page: wiki_page_params, edit_summary: 'create wiki page' }) }.
        to change { Activity.where(event: Activity::CREATE).count }.by(1)

      activity = Activity.last
      wiki_page = WikiPage.last
      expect(activity.trackable).to eq wiki_page
      expect(activity.edit_summary).to eq "create wiki page"
      expect(activity.parameters).to eq(title: wiki_page.title)
    end
  end

  describe "GET edit", as: :user do
    let!(:wiki_page) { create :wiki_page }

    specify { expect(get(:edit, params: { id: wiki_page.id })).to render_template :edit }
  end

  describe "PUT update", as: :user do
    let!(:wiki_page) { create :wiki_page }
    let!(:wiki_page_params) do
      {
        title: 'Title',
        content: 'content'
      }
    end

    it 'updates the wiki page' do
      put(:update, params: { id: wiki_page.id, wiki_page: wiki_page_params })

      wiki_page.reload
      expect(wiki_page.title).to eq wiki_page_params[:title]
      expect(wiki_page.content).to eq wiki_page_params[:content]
    end
  end

  describe "DELETE destroy", as: :current_user do
    let(:current_user) { create(:user, :superadmin, :editor) }
    let!(:wiki_page) { create :wiki_page }

    it 'deletes the wiki page' do
      expect { delete(:destroy, params: { id: wiki_page.id }) }.to change { WikiPage.count }.by(-1)
    end

    it 'creates an activity' do
      expect { delete(:destroy, params: { id: wiki_page.id }) }.
        to change { Activity.where(event: Activity::DESTROY, trackable: wiki_page).count }.by(1)

      activity = Activity.last
      expect(activity.parameters).to eq(title: wiki_page.title)
    end
  end
end
