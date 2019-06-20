require 'spec_helper'

describe InstitutionsController do
  describe "forbidden actions" do
    context "when signed in as a user" do
      before { sign_in create(:user) }

      specify { expect(get(:new)).to have_http_status :forbidden }
      specify { expect(get(:edit, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(post(:create)).to have_http_status :forbidden }
      specify { expect(put(:update, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(delete(:destroy, params: { id: 1 })).to have_http_status :forbidden }
    end

    context "when signed in as a helper editor" do
      before { sign_in create(:user, :helper) }

      specify { expect(get(:edit, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(put(:update, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(delete(:destroy, params: { id: 1 })).to have_http_status :forbidden }
    end

    context "when signed in as an editor" do
      before { sign_in create(:user, :editor) }

      specify { expect(delete(:destroy, params: { id: 1 })).to have_http_status :forbidden }
    end
  end
end
