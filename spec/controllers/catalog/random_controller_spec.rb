require 'spec_helper'

describe Catalog::RandomController do
  describe 'GET show' do
    let!(:taxon) { create :family }

    it "redirects to a random catalog page" do
      get :show
      expect(response).to redirect_to catalog_path(taxon)
    end
  end
end
