# frozen_string_literal: true

require 'rails_helper'

# Requests seen from bots that used to end in a 500.
describe "Catalog requests from bots" do
  describe "an HTML-only page requested as JSON" do
    before { create :family }

    it "answers 406 instead of an error" do
      get root_path, headers: { 'Accept' => 'application/json' }
      expect(response).to have_http_status :not_acceptable
    end
  end

  describe "a taxon browser `view` that does not apply to the taxon's rank" do
    let!(:species) { create :species }

    it "ignores the view" do
      get catalog_path(species, view: 'all_taxa_in_genus')
      expect(response).to have_http_status :ok
    end

    it "ignores unknown views" do
      get catalog_path(species, view: 'not_a_view')
      expect(response).to have_http_status :ok
    end
  end
end
