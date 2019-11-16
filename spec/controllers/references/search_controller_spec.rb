require 'rails_helper'

describe References::SearchController do
  describe "GET index" do
    describe "search terms matching ids" do
      context "when reference exists" do
        let!(:reference) { create :article_reference }

        it "redirects to the reference" do
          get :index, params: { reference_q: reference.id }
          expect(response).to redirect_to reference_path(reference)
        end
      end

      context "when reference does not exists" do
        it "does not redirect" do
          get :index, params: { reference_q: "11111" }
          expect(response).to render_template "references/search/index"
        end
      end
    end
  end
end
