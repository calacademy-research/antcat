require "spec_helper"

describe SiteNoticesController do
  let!(:editor) { create :editor }
  let!(:site_notice) { create :site_notice }
  before do
    sign_in editor
    @request.env["HTTP_REFERER"] = "http://antcat.org"
  end

  describe "GET show" do
    before do
      sleep 1
      @another_site_notice = create :site_notice
    end

    it "marks as read " do
      expect { get :show, id: @another_site_notice.id }
        .to change { SiteNotice.unread_by(editor).count }.by -1
    end
  end

  describe "POST mark_all_as_read" do
    it "calls SiteNotice" do
      expect(SiteNotice).to receive :mark_as_read!
      post :mark_all_as_read
    end
  end

  describe "POST dismiss" do
    let!(:last_site_notice_id) { SiteNotice.last.id }
    before { post :dismiss }

    it { is_expected.to set_session[:last_dismissed_site_notice_id].to last_site_notice_id }
  end
end
