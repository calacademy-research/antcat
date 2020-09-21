# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::PublishersController, as: :visitor do
  describe "GET index" do
    specify do
      publisher = create :publisher
      get :index
      expect(json_response).to eq([publisher.as_json(root: true)])
    end

    specify { expect(get(:index)).to have_http_status :ok }
  end

  describe "GET show" do
    let!(:publisher) { create :publisher }

    specify do
      get :show, params: { id: publisher.id }
      expect(json_response).to eq(
        {
          "publisher" => {
            "id" => publisher.id,
            "name" => publisher.name,
            "place" => publisher.place,

            "created_at" => publisher.created_at.as_json,
            "updated_at" => publisher.updated_at.as_json
          }
        }
      )
    end

    specify { expect(get(:show, params: { id: publisher.id })).to have_http_status :ok }
  end
end
