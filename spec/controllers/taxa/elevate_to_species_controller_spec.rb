require 'spec_helper'

describe Taxa::ElevateToSpeciesController do
  describe "forbidden actions" do
    context "when signed in as a user" do
      before { sign_in create(:user) }

      specify { expect(post(:create, params: { taxa_id: 1 })).to have_http_status :forbidden }
    end
  end

  describe '#create' do
    let!(:subspecies) { create :subspecies }

    before { sign_in create(:user, :editor) }

    it 'calls `Taxa::ElevateToSpecies`' do
      expect(Taxa::ElevateToSpecies).to receive(:new).with(subspecies).and_call_original
      post :create, params: { taxa_id: subspecies.id }
    end

    it 'creates an activity', :feed do
      expect { post :create, params: { taxa_id: subspecies.id } }.to change { Activity.count }.by(1)

      activity = Activity.last
      expect(activity.action).to eq 'elevate_subspecies_to_species'
      expect(activity.trackable).to be_a Species
      expect(activity.parameters).to eq(
        name: "<i>#{activity.trackable.name.name}</i>",
        name_was: "<i>#{subspecies.name.name}</i>",
        original_subspecies_id: subspecies.id
      )
    end
  end
end
