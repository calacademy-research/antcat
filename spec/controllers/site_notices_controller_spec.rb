# frozen_string_literal: true

require 'rails_helper'

describe SiteNoticesController do
  describe "forbidden actions" do
    context "when not signed in", as: :visitor do
      specify { expect(post(:show, params: { id: 1 })).to redirect_to_signin_form }
      specify { expect(post(:mark_all_as_read)).to redirect_to_signin_form }
    end

    context "when signed in as a user", as: :user do
      specify { expect(get(:new)).to have_http_status :forbidden }
      specify { expect(get(:edit, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(post(:create)).to have_http_status :forbidden }
      specify { expect(post(:update, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(delete(:destroy, params: { id: 1 })).to have_http_status :forbidden }
    end

    context "when signed in as an editor", as: :editor do
      specify { expect(delete(:destroy, params: { id: 1 })).to have_http_status :forbidden }
    end
  end

  describe "GET index", as: :visitor do
    specify { expect(get(:index)).to render_template :index }
  end

  describe "GET show", as: :current_user do
    let(:current_user) { create :user }

    before do
      create :site_notice
      create :site_notice, created_at: 1.second.from_now # HACK: Set `created_at` due to how the `unread` gem works.
    end

    it "marks it as read" do
      expect { get :show, params: { id: SiteNotice.last.id } }.
        to change { SiteNotice.unread_by(current_user).count }.by(-1)
    end
  end

  describe "GET new", as: :editor do
    specify { expect(get(:new)).to render_template :new }
  end

  describe "POST create", as: :editor do
    let!(:site_notice_params) do
      {
        title: 'Title',
        message: 'message'
      }
    end

    it 'creates a site notice' do
      expect { post(:create, params: { site_notice: site_notice_params }) }.to change { SiteNotice.count }.by(1)

      site_notice = SiteNotice.last
      expect(site_notice.title).to eq site_notice_params[:title]
      expect(site_notice.message).to eq site_notice_params[:message]
    end

    it 'creates an activity' do
      expect { post(:create, params: { site_notice: site_notice_params, edit_summary: 'summary' }) }.
        to change { Activity.where(event: Activity::CREATE).count }.by(1)

      activity = Activity.last
      site_notice = SiteNotice.last
      expect(activity.trackable).to eq site_notice
      expect(activity.edit_summary).to eq "summary"
      expect(activity.parameters).to eq(title: site_notice.title)
    end
  end

  describe "GET edit", as: :editor do
    let!(:site_notice) { create :site_notice }

    specify { expect(get(:edit, params: { id: site_notice.id })).to render_template :edit }
  end

  describe "PUT update", as: :editor do
    let!(:site_notice) { create :site_notice }
    let!(:site_notice_params) do
      {
        title: 'Title',
        message: 'message'
      }
    end

    it 'updates the site notice' do
      post(:update, params: { id: site_notice.id, site_notice: site_notice_params })

      site_notice.reload
      expect(site_notice.title).to eq site_notice_params[:title]
      expect(site_notice.message).to eq site_notice_params[:message]
    end

    it 'creates an activity' do
      expect { post(:update, params: { id: site_notice.id, site_notice: site_notice_params, edit_summary: 'summary' }) }.
        to change { Activity.where(event: Activity::UPDATE, trackable: site_notice).count }.by(1)

      activity = Activity.last
      site_notice.reload
      expect(activity.edit_summary).to eq "summary"
      expect(activity.parameters).to eq(title: site_notice.title)
    end
  end

  describe "DELETE destroy", as: :current_user do
    let(:current_user) { create(:user, :superadmin, :editor) }
    let!(:site_notice) { create :site_notice }

    it 'deletes the site notice' do
      expect { delete(:destroy, params: { id: site_notice.id }) }.to change { SiteNotice.count }.by(-1)
    end

    it 'creates an activity' do
      expect { delete(:destroy, params: { id: site_notice.id }) }.
        to change { Activity.where(event: Activity::DESTROY, trackable: site_notice).count }.by(1)

      activity = Activity.last
      expect(activity.parameters).to eq(title: site_notice.title)
    end
  end

  describe "POST #mark_all_as_read", as: :current_user do
    let(:current_user) { create(:user) }

    after { post :mark_all_as_read }

    it "calls `SiteNotice#mark_as_read`" do
      expect(SiteNotice).to receive(:mark_as_read!).with(:all, for: current_user)
    end
  end
end
