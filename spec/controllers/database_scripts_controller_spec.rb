require 'spec_helper'

describe DatabaseScriptsController do
  describe "forbidden actions" do
    context "when signed in as a user" do
      before { sign_in create(:user) }

      specify { expect(get(:show, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(get(:source, params: { id: 1 })).to have_http_status :forbidden }
    end
  end
end
