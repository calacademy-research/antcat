require 'spec_helper'

describe Taxa::ReorderHistoryItemsController do
  describe "forbidden actions" do
    context "when signed in as a user" do
      before { sign_in create(:user) }

      specify { expect(post(:create, params: { taxa_id: 1 })).to have_http_status :forbidden }
    end
  end

  describe "POST create" do
    # TODO: Add specs since the Cucumber tests are flaky.
  end
end
