require "spec_helper"

describe SiteNoticesController do
  let!(:editor) { create :user, :editor }

  before do
    sign_in editor
    request.env["HTTP_REFERER"] = "http://antcat.org"
  end

  describe "forbidden actions" do
    context "when not signed in" do
      before { sign_out editor }

      specify { expect(post(:show, params: { id: 1 })).to redirect_to_signin_form }
      specify { expect(post(:mark_all_as_read)).to redirect_to_signin_form }
    end

    context "when signed in as a user" do
      before { sign_in create(:user) }

      specify { expect(get(:new)).to have_http_status :forbidden }
      specify { expect(get(:edit, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(post(:create)).to have_http_status :forbidden }
      specify { expect(post(:update, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(delete(:destroy, params: { id: 1 })).to have_http_status :forbidden }
    end

    context "when signed in as an editor" do
      before { sign_in create(:user, :editor) }

      specify { expect(delete(:destroy, params: { id: 1 })).to have_http_status :forbidden }
    end
  end

  describe "GET show" do
    before do
      create :site_notice
      # Manually specify `created_at` due to how the `unread` gem works.
      create :site_notice, created_at: 1.second.from_now
    end

    it "marks it as read" do
      expect { get :show, params: { id: SiteNotice.last.id } }.
        to change { SiteNotice.unread_by(editor).count }.by(-1)
    end
  end

  describe "POST create" do
    let!(:site_notice_params) do
      {
        title: 'Title',
        message: 'message'
      }
    end

    before { sign_in create(:user, :editor) }

    it 'creates a site notice' do
      expect { post(:create, params: { site_notice: site_notice_params }) }.to change { SiteNotice.count }.by(1)

      site_notice = SiteNotice.last
      expect(site_notice.title).to eq site_notice_params[:title]
      expect(site_notice.message).to eq site_notice_params[:message]
    end

    it 'creates an activity' do
      expect { post(:create, params: { site_notice: site_notice_params }) }.
        to change { Activity.where(action: :create).count }.by(1)

      activity = Activity.last
      site_notice = SiteNotice.last
      expect(activity.trackable).to eq site_notice
      expect(activity.parameters).to eq(title: site_notice.title)
    end
  end

  describe "POST update" do
    let!(:site_notice) { create :site_notice }
    let!(:site_notice_params) do
      {
        title: 'Title',
        message: 'message'
      }
    end

    before { sign_in create(:user, :editor) }

    it 'updates the site notice' do
      post(:update, params: { id: site_notice.id, site_notice: site_notice_params })

      site_notice.reload
      expect(site_notice.title).to eq site_notice_params[:title]
      expect(site_notice.message).to eq site_notice_params[:message]
    end

    it 'creates an activity' do
      expect { post(:update, params: { id: site_notice.id, site_notice: site_notice_params }) }.
        to change { Activity.where(action: :update, trackable: site_notice).count }.by(1)

      activity = Activity.last
      site_notice.reload
      expect(activity.parameters).to eq(title: site_notice.title)
    end
  end

  describe "DELETE destroy" do
    let!(:site_notice) { create :site_notice }

    before { sign_in create(:user, :superadmin, :editor) }

    it 'deletes the site notice' do
      expect { delete(:destroy, params: { id: site_notice.id }) }.to change { SiteNotice.count }.by(-1)
    end

    it 'creates an activity' do
      expect { delete(:destroy, params: { id: site_notice.id }) }.
        to change { Activity.where(action: :destroy, trackable: site_notice).count }.by(1)

      activity = Activity.last
      expect(activity.parameters).to eq(title: site_notice.title)
    end
  end

  describe "POST #mark_all_as_read" do
    after { post :mark_all_as_read }

    it "calls `SiteNotice#mark_as_read`" do
      expect(SiteNotice).to receive(:mark_as_read!).with(:all, for: editor)
    end
  end
end
