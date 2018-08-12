require 'spec_helper'

describe TooltipsController do
  describe "forbidden actions" do
    context "when signed in as a user" do
      before { sign_in create(:user) }

      specify { expect(get(:index)).to have_http_status :forbidden }
      specify { expect(get(:new)).to have_http_status :forbidden }
      specify { expect(get(:show, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(get(:edit, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(post(:create)).to have_http_status :forbidden }
      specify { expect(post(:update, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(delete(:destroy, params: { id: 1 })).to have_http_status :forbidden }
    end
  end

  describe "GET index" do
    context "when signed in" do
      let!(:no_namespace)         { create :tooltip, key: "no_namespace" }
      let!(:references_authors)   { create :tooltip, key: "authors", scope: "references" }
      let!(:references_title)     { create :tooltip, key: "title", scope: "references" }
      let!(:references_new_title) { create :tooltip, key: "new.title", scope: "references" }
      let!(:taxa_type_species)    { create :tooltip, key: "type_species", scope: "taxa" }

      before { sign_in create(:user, :editor) }

      describe "grouping" do
        before do
          get :index
          @grouped = assigns :grouped_tooltips
        end

        it "creates keys for each namespace" do
          expect(@grouped.key?(nil)).to be true
          expect(@grouped.key?("references")).to be true
          expect(@grouped.key?("taxa")).to be true
        end

        it "groups keys without namespaces in the 'nil' bucket" do
          expect(@grouped[nil]).to eq [no_namespace]
        end

        it "groups keys with namespaces" do
          expect(@grouped["references"]).
            to eq [references_authors, references_new_title, references_title]
          expect(@grouped["taxa"]).to eq [taxa_type_species]
        end

        it "includes all items" do
          expect(@grouped.values.flatten.size).to eq Tooltip.count
        end
      end
    end
  end
end
