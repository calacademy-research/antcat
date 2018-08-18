require 'spec_helper'

describe MergeAuthorsController do
  describe "forbidden actions" do
    context "when signed in as a user" do
      before { sign_in create(:user) }

      specify { expect(post(:merge, params: { id: 1 })).to have_http_status :forbidden }
    end
  end
end
