# frozen_string_literal: true

require 'rails_helper'

describe Publishers::AutocompletesController do
  describe "GET show", as: :visitor do
    it "calls `Autocomplete::PublishersQuery`" do
      expect(Autocomplete::PublishersQuery).to receive(:new).with("query").and_call_original
      get :show, params: { term: "query" }
    end

    context 'with publishers' do
      let!(:publisher) { create :publisher, name: 'Libros' }

      it "returns publishers in an array" do
        get :show, params: { term: "libros" }
        expect(json_response).to eq [publisher.display_name]
      end
    end
  end
end
