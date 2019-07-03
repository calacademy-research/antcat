require "spec_helper"

describe SiteNoticesController do
  let!(:editor) { create :user, :editor }

  before do
    sign_in editor
    @request.env["HTTP_REFERER"] = "http://antcat.org"
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
    let!(:site_notice) { create :site_notice }
    # Manually specify `created_at` due to how the `unread` gem's usage of timestamps.
    let!(:another_site_notice) { create :site_notice, created_at: 1.second.from_now }

    it "marks it as read" do
      expect { get :show, params: { id: another_site_notice.id } }.
        to change { SiteNotice.unread_by(editor).count }.by(-1)
    end
  end

  describe "POST #mark_all_as_read" do
    after { post :mark_all_as_read }

    it "calls `SiteNotice#mark_as_read`" do
      expect(SiteNotice).to receive(:mark_as_read!).with(:all, for: editor)
    end
  end
end
