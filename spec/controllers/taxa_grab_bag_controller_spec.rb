require 'spec_helper'

describe TaxaGrabBagController do
  describe "forbidden actions" do
    context "when signed in as a user" do
      before { sign_in create(:user) }

      specify { expect(post(:destroy_unreferenced, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(post(:elevate_to_species, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(post(:reorder_history_items, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(post(:update_parent, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(delete(:destroy, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(delete(:confirm_before_delete, params: { id: 1 })).to have_http_status :forbidden }
    end

    context "when signed in as an editor" do
      before { sign_in create(:user, :editor) }

      specify { expect(delete(:destroy, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(delete(:confirm_before_delete, params: { id: 1 })).to have_http_status :forbidden }
    end
  end
end
