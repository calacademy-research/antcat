require 'spec_helper'

describe CatalogController do

  it { should use_before_action(:handle_family_not_found) }
  it { should use_before_action(:setup_catalog) }

  describe 'GET #index' do
    describe "handle non-existing family" do
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
  end

  describe 'GET #show' do
    describe "RecordNotFound" do
      before { create :family }
      it "raises on taxon not found (=404 in prod)" do
        expect { get :show, id: 99999 }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  describe "valid_only toggler" do
    let!(:taxon) { create :family }
    before { @request.env["HTTP_REFERER"] = "http://antcat.org" }

    describe "toggles the session" do
      before { get :options, valid_only: "true" }
      it { should set_session[:show_valid_only].to(true) }
    end

    describe "toggles back" do
      before do
        get :options, valid_only: "true"
        get :options, valid_only: "false"
      end
      it { should set_session[:show_valid_only].to(false) }
    end
  end

end
