require 'spec_helper'

describe FeedbackController do
  describe "forbidden actions" do
    context "when signed in as a user" do
      before { sign_in create(:user) }

      specify { expect(get(:show, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(get(:index)).to have_http_status :forbidden }
      specify { expect(delete(:destroy, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(delete(:reopen, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(delete(:close, params: { id: 1 })).to have_http_status :forbidden }
    end

    context "when signed in as an editor" do
      before { sign_in create(:user, :editor) }

      specify { expect(delete(:destroy, params: { id: 1 })).to have_http_status :forbidden }
    end
  end
end
