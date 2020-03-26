# frozen_string_literal: true

require 'rails_helper'

describe Protonyms::Localities::AutocompletesController do
  describe "GET show", as: :visitor do
    before do
      create :protonym, locality: 'Californa'
    end

    it "returns all localities" do
      get :show, params: { format: :json }
      expect(json_response).to eq ['Californa']
    end
  end
end
