require 'spec_helper'

describe CatalogController do
  describe 'GET index' do
    context "family exists" do
      before do
        create :family
        get :index
      end

      it { should render_template('show') }
    end

    context "without a family existing in the database" do
      before { get :index }
      it { should render_template('family_not_found') }
    end
  end

  describe 'GET show' do
    context "RecordNotFound" do
      before { create :family }

      it "raises on taxon not found (=404 in prod)" do
        expect { get :show, id: 99999 }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  describe "#show_valid_only and #show_invalid" do
    let!(:taxon) { create :family }
    before { @request.env["HTTP_REFERER"] = "http://antcat.org" }

    describe "GET show_invalid" do
      before { get :show_invalid }
      it { should set_session[:show_invalid].to true }
    end

    describe "GET show_valid_only" do
      before { get :show_valid_only }
      it { should set_session[:show_invalid].to false }
    end
  end

  # TODO move to service's spec.
  describe "GET autocomplete" do
    it "works" do
      create_genus 'Atta'
      create_genus 'Ratta'
      create_genus 'Nylanderia'

      get :autocomplete, q: "att", format: :json
      json = JSON.parse response.body

      results = json.map { |taxon| taxon["name"] }.sort
      expect(results).to eq ["Atta", "Ratta"]
    end
  end
end
