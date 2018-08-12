require 'spec_helper'

describe ChangesController do
  describe "forbidden actions" do
    context "when signed in as a user" do
      before { sign_in create(:user) }

      specify { expect(post(:approve, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(post(:approve_all)).to have_http_status :forbidden }
    end

    context "when signed in as an editor" do
      before { sign_in create(:user, :editor) }

      specify { expect(post(:approve_all)).to have_http_status :forbidden }
    end
  end
end
