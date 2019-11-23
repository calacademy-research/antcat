require 'rails_helper'

describe Taxa::CreateCombinationHelpsController do
  describe "GET new" do
    let(:taxon) { create :species }

    specify { expect(get(:new, params: { taxa_id: taxon.id })).to render_template :new }
  end

  describe "GET show" do
    let(:taxon) { create :species }
    let(:new_parent) { create :genus }

    specify do
      expect(get(:show, params: { taxa_id: taxon.id, new_parent_id: new_parent.id })).to render_template :show
    end

    context 'when `new_parent_id` is missing' do
      specify do
        expect(get(:show, params: { taxa_id: taxon.id })).to redirect_to action: :new
        expect(response.request.flash[:alert]).to eq "Target must be specified."
      end
    end
  end
end
