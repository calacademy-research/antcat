# frozen_string_literal: true

require 'rails_helper'

describe Publishers::AutocompletesController do
  describe "GET show", as: :visitor do
    it "calls `Autocomplete::PublishersQuery`" do
      expect(Autocomplete::PublishersQuery).to receive(:new).with("wiley").and_call_original
      get :show, params: { term: "wiley" }
    end

    context 'with publishers' do
      let!(:publisher) { create :publisher, name: 'Wiley', place: 'California' }

      it "returns publishers in an array" do
        get :show, params: { term: "wiley" }
        expect(json_response).to eq [publisher.display_name]
      end
    end
  end
end
