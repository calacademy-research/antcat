require 'spec_helper'

describe TooltipsController do
  describe '#index' do
    context "signed in" do
      let!(:no_namespace)         { create :tooltip, key: "no_namespace" }
      let!(:references_authors)   { create :tooltip, key: "authors", scope: "references" }
      let!(:references_title)     { create :tooltip, key: "title", scope: "references" }
      let!(:references_new_title) { create :tooltip, key: "new.title", scope: "references" }
      let!(:taxa_type_species)    { create :tooltip, key: "type_species", scope: "taxa" }

      before { sign_in create :editor }

      describe "grouping" do
        before do
          get :index
          @grouped = assigns :grouped_tooltips
        end

        it "creates keys for each namespace" do
          expect(@grouped.key? nil).to be true
          expect(@grouped.key? "references").to be true
          expect(@grouped.key? "taxa").to be true
        end

        it "groups keys without namespaces in the 'nil' bucket" do
          expect(@grouped[nil]).to eq [no_namespace]
        end

        it "groups keys with namespaces" do
          expect(@grouped["references"]).to eq [
            references_authors, references_new_title, references_title]
          expect(@grouped["taxa"]).to eq [taxa_type_species]
        end

        it "includes all items" do
          expect(@grouped.values.flatten.size).to eq Tooltip.count
        end
      end
    end
  end
end
