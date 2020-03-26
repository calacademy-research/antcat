# frozen_string_literal: true

require 'rails_helper'

describe Taxa::ChildrenController do
  describe "forbidden actions" do
    context "when signed in as a user", as: :user do
      specify { expect(delete(:destroy, params: { taxa_id: 1 })).to have_http_status :forbidden }
    end

    context "when signed in as a helper", as: :helper do
      specify { expect(delete(:destroy, params: { taxa_id: 1 })).to have_http_status :forbidden }
    end
  end

  describe "GET show", as: :visitor do
    let(:taxon) { create :family }

    specify { expect(get(:show, params: { taxa_id: taxon.id })).to render_template :show }
  end

  describe "DELETE destroy", as: :editor do
    describe 'successful case' do
      let!(:taxon) { create :genus }

      before do
        create :species, genus: taxon
        create :species, genus: taxon
      end

      it 'deletes the children' do
        expect { delete(:destroy, params: { taxa_id: taxon.id }) }.to change { Taxon.count }.by(-2)
      end
    end

    context 'when rank is not supported' do
      let!(:taxon) { create :family }

      specify do
        expect { delete(:destroy, params: { taxa_id: taxon.id }) }.to_not change { Taxon.count }
        expect(response.request.flash[:alert]).to include "Deleting children is only supported for "
      end
    end

    context "when children has 'What Links Here's" do
      let!(:taxon) { create :genus }

      before do
        species = create :species, genus: taxon
        create :taxon_history_item, taxt: "see {tax #{species.id}}"
      end

      specify do
        expect { delete(:destroy, params: { taxa_id: taxon.id }) }.to_not change { Taxon.count }
        expect(response.request.flash[:alert]).to eq "Cannot delete children since at least one of them has 'What Links Here's."
      end
    end
  end
end
