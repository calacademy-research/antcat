require 'spec_helper'

describe SynonymsController do
  describe "forbidden actions" do
    context "when signed in as a user" do
      before { sign_in create(:user) }

      specify { expect(post(:create, params: { taxa_id: 1, id: 1 })).to have_http_status :forbidden }
      specify { expect(delete(:destroy, params: { taxa_id: 1, id: 1 })).to have_http_status :forbidden }
    end
  end
end
