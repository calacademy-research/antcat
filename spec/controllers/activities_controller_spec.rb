require 'spec_helper'

describe ActivitiesController do
  describe "forbidden actions" do
    context "when signed in as a user" do
      before { sign_in create(:user) }

      specify { expect(delete(:destroy, params: { id: 1 })).to have_http_status :forbidden }
    end

    context "when signed in as an editor" do
      before { sign_in create(:user, :editor) }

      specify { expect(delete(:destroy, params: { id: 1 })).to have_http_status :forbidden }
    end
  end
end
