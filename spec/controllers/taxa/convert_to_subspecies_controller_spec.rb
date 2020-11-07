# frozen_string_literal: true

require 'rails_helper'

describe Taxa::ConvertToSubspeciesController do
  describe "forbidden actions" do
    context "when signed in as a user", as: :user do
      specify { expect(get(:new, params: { taxa_id: 1 })).to have_http_status :forbidden }
      specify { expect(post(:create, params: { taxa_id: 1 })).to have_http_status :forbidden }
    end
  end

  describe 'POST create', as: :editor do
    let!(:species) { create :species }
    let!(:new_species) { create :species, genus: species.genus }

    it 'calls `Taxa::Operations::ConvertToSubspecies`' do
      expect(Taxa::Operations::ConvertToSubspecies).to receive(:new).with(species, new_species).and_call_original
      post :create, params: { taxa_id: species.id, new_species_id: new_species.id }
    end

    it 'creates an activity' do
      expect { post :create, params: { taxa_id: species.id, new_species_id: new_species.id } }.
        to change { Activity.count }.by(1)

      activity = Activity.last
      expect(activity.action).to eq Activity::CONVERT_SPECIES_TO_SUBSPECIES
      expect(activity.trackable).to be_a Subspecies
      expect(activity.parameters).to eq(
        name: "<i>#{activity.trackable.name.name}</i>",
        name_was: "<i>#{species.name.name}</i>",
        original_species_id: species.id
      )
    end
  end
end
