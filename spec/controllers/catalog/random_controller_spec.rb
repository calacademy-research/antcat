# frozen_string_literal: true

require 'rails_helper'

describe Catalog::RandomController do
  describe 'GET show', as: :visitor do
    let!(:taxon) { create :family }

    it "redirects to a random catalog page" do
      get :show
      expect(response).to redirect_to catalog_path(taxon)
    end
  end
end
