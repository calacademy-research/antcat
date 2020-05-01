# frozen_string_literal: true

require 'rails_helper'

describe Protonyms::AutocompletesController do
  describe "GET show", as: :visitor do
    it "calls `Autocomplete::ProtonymsQuery`" do
      expect(Autocomplete::ProtonymsQuery).to receive(:new).with("lasius").and_call_original
      get :show, params: { qq: "lasius", format: :json }
    end

    specify do
      protonym = create :protonym, name: create(:genus_name, name: 'Lasius')

      get :show, params: { qq: 'las', format: :json }
      expect(json_response).to eq(
        [
          {
            'id' => protonym.id,
            'name_with_fossil' => protonym.decorate.protonym.decorate.name_with_fossil,
            'author_citation' => protonym.authorship.reference.keey_without_letters_in_year,
            'url' => "/protonyms/#{protonym.id}"
          }
        ]
      )
    end
  end
end
