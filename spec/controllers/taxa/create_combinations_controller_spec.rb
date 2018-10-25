require 'spec_helper'

describe Taxa::CreateCombinationsController do
  describe "forbidden actions" do
    context "when signed in as a user" do
      before { sign_in create(:user) }

      specify { expect(get(:new, params: { taxa_id: 1 })).to have_http_status :forbidden }
      specify { expect(get(:show, params: { taxa_id: 1 })).to have_http_status :forbidden }
    end
  end
end
