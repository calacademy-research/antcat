require 'spec_helper'

describe TaxaController do
  describe "forbidden actions" do
    context "when signed in as a user" do
      before { sign_in create(:user) }

      specify { expect(get(:new)).to have_http_status :forbidden }
      specify { expect(get(:edit, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(post(:create)).to have_http_status :forbidden }
      specify { expect(post(:update, params: { id: 1 })).to have_http_status :forbidden }
    end
  end

  describe "#build_relationships" do
    it "builds" do
      taxon = controller.send :build_new_taxon, :species

      expect(taxon.name).not_to be_blank
      expect(taxon.type_name).not_to be_blank
      expect(taxon.protonym).not_to be_blank
      expect(taxon.protonym.name).not_to be_blank
      expect(taxon.protonym.authorship).not_to be_blank
    end
  end
end
