require 'spec_helper'

describe References::ReviewsController do
  describe "forbidden actions" do
    context "when signed in as a user" do
      before { sign_in create(:user) }

      specify { expect(post(:start, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(post(:finish, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(post(:restart, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(post(:approve_all, params: { id: 1 })).to have_http_status :forbidden }
    end

    context "when signed in as an editor" do
      before { sign_in create(:user, :editor) }

      specify { expect(post(:approve_all, params: { id: 1 })).to have_http_status :forbidden }
    end
  end
end
