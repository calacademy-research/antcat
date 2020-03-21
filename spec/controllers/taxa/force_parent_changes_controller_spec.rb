require 'rails_helper'

describe Taxa::ForceParentChangesController do
  describe "forbidden actions" do
    context "when signed in as a user", as: :user do
      specify { expect(get(:show, params: { taxa_id: 1 })).to have_http_status :forbidden }
      specify { expect(post(:create, params: { taxa_id: 1 })).to have_http_status :forbidden }
    end
  end

  describe "GET show", as: :editor do
    let(:taxon) { create :genus }

    specify { expect(get(:show, params: { taxa_id: taxon.id })).to render_template :show }
  end

  describe "POST create", as: :editor do
    let(:taxon) { create :genus }
    let(:new_parent) { create :family }

    it "calls `Taxa::Operations::ForceParentChange`" do
      expect(Taxa::Operations::ForceParentChange).
        to receive(:new).with(taxon, new_parent).and_call_original
      post :create, params: { taxa_id: taxon.id, new_parent_id: new_parent.id }
    end

    context 'when `new_parent_id` is missing' do
      context "when taxon isn't a genus" do
        let(:taxon) { create :species }

        it 'requires a parent' do
          post :create, params: { taxa_id: taxon.id }

          expect(response).to render_template :show
          expect(response.request.flash[:alert]).to eq "A parent must be set."
        end
      end

      context 'when taxon is a genus' do
        let(:taxon) { create :genus }

        it 'does not require a parent (genera can be incertae sedis in Formicidae)' do
          post :create, params: { taxa_id: taxon.id }

          expect(response).to redirect_to catalog_path(taxon)
          expect(response.request.flash[:notice]).to eq "Successfully changed the parent."
        end
      end
    end
  end
end
