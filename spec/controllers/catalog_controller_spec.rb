require 'spec_helper'

describe CatalogController do
  describe 'GET index' do
    context "family exists" do
      before do
        create :family
        get :index
      end

      it { expect(response).to render_template :show }
    end

    context "without a family existing in the database" do
      before { get :index }

      specify { expect(response).to render_template :family_not_found }
    end
  end

  describe 'GET show' do
    context "RecordNotFound" do
      before { create :family }

      it "raises on taxon not found (=404 in prod)" do
        expect { get :show, params: { id: 99999 } }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  describe "#show_valid_only and #show_invalid" do
    before do
      create :family
      @request.env["HTTP_REFERER"] = "http://antcat.org"
    end

    describe "GET show_invalid" do
      before { get :show_invalid }

      it { is_expected.to set_session[:show_invalid].to true }
    end

    describe "GET show_valid_only" do
      before { get :show_valid_only }

      it { is_expected.to set_session[:show_invalid].to false }
    end
  end

  describe "GET autocomplete" do
    let!(:atta) { create_genus "Atta" }
    let!(:ratta) { create_genus "Ratta" }

    before do
      create_genus "Nylanderia"
      get :autocomplete, params: { q: "att", format: :json }
    end

    it "returns matches" do
      results = json_response.map { |taxon| taxon["id"] }
      expect(results).to eq [atta.id, ratta.id]
    end
  end
end
