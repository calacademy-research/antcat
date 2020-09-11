# frozen_string_literal: true

require 'rails_helper'

describe References::SearchController do
  describe "GET index", as: :visitor do
    describe "search queries matching reference ids" do
      context "when reference exists" do
        let!(:reference) { create :any_reference }

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
