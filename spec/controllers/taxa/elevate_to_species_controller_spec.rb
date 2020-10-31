# frozen_string_literal: true

require 'rails_helper'

describe Taxa::ElevateToSpeciesController do
  describe "forbidden actions" do
    context "when signed in as a user", as: :user do
      specify { expect(post(:create, params: { taxa_id: 1 })).to have_http_status :forbidden }
    end
  end

  describe 'POST create', as: :editor do
    let!(:subspecies) { create :subspecies }

    it 'calls `Taxa::Operations::ElevateToSpecies`' do
      expect(Taxa::Operations::ElevateToSpecies).to receive(:new).with(subspecies).and_call_original
      post :create, params: { taxa_id: subspecies.id }
    end

    it 'creates an activity' do
      expect { post :create, params: { taxa_id: subspecies.id } }.to change { Activity.count }.by(1)

      activity = Activity.last
      expect(activity.action).to eq Activity::ELEVATE_SUBSPECIES_TO_SPECIES
      expect(activity.trackable).to be_a Species
      expect(activity.parameters).to eq(
        name: "<i>#{activity.trackable.name.name}</i>",
        name_was: "<i>#{subspecies.name.name}</i>",
        original_subspecies_id: subspecies.id
      )
    end
  end
end
