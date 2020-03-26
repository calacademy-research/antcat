# frozen_string_literal: true

require 'rails_helper'

describe Taxa::SetSubgeneraController do
  include TestLinksHelpers

  render_views

  describe "forbidden actions" do
    context "when signed in as a user", as: :user do
      specify { expect(get(:show, params: { taxa_id: 1 })).to have_http_status :forbidden }
      specify { expect(post(:create, params: { taxa_id: 1 })).to have_http_status :forbidden }
      specify { expect(delete(:destroy, params: { taxa_id: 1 })).to have_http_status :forbidden }
    end
  end

  describe "POST create", as: :editor do
    let!(:taxon) { create :species }
    let!(:subgenus) { create :subgenus, genus: taxon.genus }

    it "set the subgenus of the species" do
      expect { post :create, params: { taxa_id: taxon.id, subgenus_id: subgenus.id } }.
        to change { taxon.reload.subgenus }.from(nil).to(subgenus)
    end

    it 'creates an activity' do
      expect { post :create, params: { taxa_id: taxon.id, subgenus_id: subgenus.id } }.
        to change { Activity.where(action: :set_subgenus, trackable: taxon).count }.by(1)

      activity = Activity.last
      expect(activity.parameters).to eq set_subgenus_id_to: subgenus.id
      expect(activity.decorate.did_something.squish).to eq <<~HTML.squish
        set the subgenus of #{taxon_link(taxon)} to #{taxon_link(subgenus)}
      HTML
    end
  end

  describe "DELETE destroy", as: :editor do
    let!(:genus) { create :genus }
    let!(:subgenus) { create :subgenus, genus: genus }
    let!(:taxon) { create :species, genus: genus, subgenus: subgenus }

    it "removes the subgenus from the species" do
      expect { delete :destroy, params: { taxa_id: taxon.id, subgenus_id: subgenus.id } }.
        to change { taxon.reload.subgenus }.from(subgenus).to(nil)
    end

    it 'creates an activity' do
      expect { delete :destroy, params: { taxa_id: taxon.id, subgenus_id: subgenus.id } }.
        to change { Activity.where(action: :set_subgenus, trackable: taxon).count }.by(1)

      activity = Activity.last
      expect(activity.parameters).to eq removed_subgenus_id: subgenus.id
      expect(activity.decorate.did_something.squish).to eq <<~HTML.squish
        removed the subgenus from #{taxon_link(taxon)} (subgenus was #{taxon_link(subgenus)})
      HTML
    end
  end
end
