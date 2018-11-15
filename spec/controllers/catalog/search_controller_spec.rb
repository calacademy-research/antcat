require 'spec_helper'

describe Catalog::SearchController do
  describe "GET index" do
    specify do
      get :index
      expect(response).to render_template :index
    end

    it "does not assign `@is_quick_search`" do
      get :index
      expect(assigns(:is_quick_search)).to eq nil
    end
  end

  describe "GET quick_search" do
    specify do
      get :quick_search, params: { qq: "Atta", im_feeling_lucky: "true" }
      expect(response).to render_template :index
    end

    it "assigns `@is_quick_search`" do
      get :quick_search, params: { qq: "Atta", im_feeling_lucky: "true" }
      expect(assigns(:is_quick_search)).to eq true
    end

    context "when `qq` is blank but `im_feeling_lucky` present (searching for nothing in the header)" do
      it "does not assign `@is_quick_search`" do
        get :quick_search, params: { qq: "",  im_feeling_lucky: "true" }
        expect(assigns(:is_quick_search)).to eq nil
      end
    end
  end
end
