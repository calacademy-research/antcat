require 'rails_helper'

describe EditorsPanels::VersionsController do
  describe "forbidden actions" do
    context "when signed in as a user" do
      before { sign_in create(:user) }

      specify { expect(get(:index)).to have_http_status :forbidden }
      specify { expect(get(:show, params: { id: 1 })).to have_http_status :forbidden }
    end
  end
end
