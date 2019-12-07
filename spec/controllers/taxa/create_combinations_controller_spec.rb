require 'rails_helper'

describe Taxa::CreateCombinationsController do
  describe "forbidden actions" do
    context "when signed in as a user" do
      before { sign_in create(:user) }

      specify { expect(get(:new, params: { taxa_id: 1 })).to have_http_status :forbidden }
      specify { expect(get(:show, params: { taxa_id: 1 })).to have_http_status :forbidden }
      specify { expect(post(:create, params: { taxa_id: 1 })).to have_http_status :forbidden }
    end
  end

  describe "GET new" do
    let(:taxon) { create :species }

    before { sign_in create(:user, :editor) }

    specify { expect(get(:new, params: { taxa_id: taxon.id })).to render_template :new }
  end

  describe "GET show" do
    let(:taxon) { create :species }
    let(:new_parent) { create :genus }

    before { sign_in create(:user, :editor) }

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

  describe "POST create" do
    let!(:taxon) do
      create :species, name_string: 'Oecodoma mexicana', genus: create(:genus, name_string: 'Oecodoma')
    end
    let!(:new_parent) { create :genus, name_string: 'Atta' }
    let!(:target_name_string) { 'Atta mexicana' }
    let!(:valid_params) { { taxa_id: taxon.id, new_parent_id: new_parent.id, species_epithet: 'mexicana' } }

    before { sign_in create(:user, :editor) }

    it 'calls `Operations::CreateNewCombination`' do
      expect(Operations::CreateNewCombination).to receive(:new).with(
        current_valid_taxon: taxon,
        new_genus: new_parent,
        target_name_string: target_name_string
      ).and_call_original
      post :create, params: valid_params
    end

    context 'when operation is successful' do
      it 'creates a new taxon' do
        expect { post :create, params: valid_params }.to change { Taxon.count }.by(1)
      end

      it 'creates an activity' do
        expect { post(:create, params: valid_params) }.
          to change { Activity.where(action: :create_new_combination).count }.by(1)

        activity = Activity.last
        new_combination = taxon.reload.current_valid_taxon
        expect(activity.trackable).to eq new_combination
        expect(activity.parameters).to eq(previous_combination_id: taxon.id)
      end
    end

    context 'when operation fails' do
      let(:taxon_history_item) { create :taxon_history_item, taxon: taxon }

      before do
        taxon_history_item.update_columns(taxt: '') # Artificially create history item in an invalid state.
      end

      it 'does not create a new taxon' do
        expect { post :create, params: valid_params }.to_not change { Taxon.count }
      end

      it 'renders errors' do
        post :create, params: valid_params
        expect(response).to render_template :show
        expect(response.request.flash[:alert]).to eq "Could not update history item ##{taxon_history_item.id}"
      end
    end
  end
end
