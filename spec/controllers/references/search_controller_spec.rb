require 'spec_helper'

describe References::SearchController do
  describe "GET index" do
    describe "search terms matching ids" do
      context "when reference exists" do
        let!(:reference) { reference_factory author_name: 'E.O. Wilson', id: 99999 }

        it "redirects to #show" do
          get :index, params: { reference_q: reference.id }
          expect(response).to redirect_to reference_path(reference)
        end
      end

      context "when reference does not exists" do
        it "does not redirect unless the reference exists" do
          get :index, params: { reference_q: "11111" }
          expect(response).to render_template "references/search/index"
        end
      end
    end
  end
end
