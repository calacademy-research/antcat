# frozen_string_literal: true

require 'rails_helper'

describe Taxa::CreateCombinationsController do
  describe "forbidden actions" do
    context "when signed in as a user", as: :user do
      specify { expect(get(:new, params: { taxon_id: 1 })).to have_http_status :forbidden }
      specify { expect(get(:show, params: { taxon_id: 1 })).to have_http_status :forbidden }
      specify { expect(post(:create, params: { taxon_id: 1 })).to have_http_status :forbidden }
    end
  end

  describe "GET new", as: :editor do
    let(:taxon) { create :species }

    specify { expect(get(:new, params: { taxon_id: taxon.id })).to render_template :new }
  end

  describe "GET show", as: :editor do
    let(:taxon) { create :species }
    let(:new_parent) { create :genus }

    specify do
      expect(get(:show, params: { taxon_id: taxon.id, new_parent_id: new_parent.id })).to render_template :show
    end

    context 'when `new_parent_id` is missing' do
      specify do
        expect(get(:show, params: { taxon_id: taxon.id })).to redirect_to action: :new
        expect(response.request.flash[:alert]).to eq "Target must be specified."
      end
    end
  end

  describe "POST create", as: :editor do
    let!(:taxon) do
      create :species, name_string: 'Oecodoma mexicana', genus: create(:genus, name_string: 'Oecodoma')
    end
    let!(:new_parent) { create :genus, name_string: 'Atta' }
    let!(:target_name_string) { 'Atta mexicana' }
    let!(:valid_params) { { taxon_id: taxon.id, new_parent_id: new_parent.id, species_epithet: 'mexicana' } }

    it 'calls `Operations::CreateNewCombination`' do
      expect(Operations::CreateNewCombination).to receive(:new).with(
        current_taxon: taxon,
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
          to change { Activity.where(event: Activity::CREATE_NEW_COMBINATION).count }.by(1)

        activity = Activity.last
        new_combination = taxon.reload.current_taxon
        expect(activity.trackable).to eq new_combination
        expect(activity.parameters).to eq(previous_combination_id: taxon.id)
      end
    end

    # TODO: Use null-operation.
    context 'when operation fails' do
      before do
        create :species, name_string: target_name_string
      end

      it 'does not create a new taxon' do
        expect { post :create, params: valid_params }.to_not change { Taxon.count }
      end

      it 'renders errors' do
        post :create, params: valid_params
        expect(response).to render_template :show
        expect(response.request.flash[:alert]).to eq "#{target_name_string} - This name is in use by another taxon"
      end
    end
  end
end
