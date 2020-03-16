require 'rails_helper'

describe Api::V1::PublishersController do
  describe "GET show" do
    let!(:publisher) { create :publisher, name: 'AntPress', place: 'California' }

    before { get :show, params: { id: publisher.id } }

    specify do
      expect(json_response).to eq(
        {
          "publisher" => {
            "id" => publisher.id,
            "name" => "AntPress",
            "place" => "California",
            "created_at" => publisher.created_at.as_json,
            "updated_at" => publisher.updated_at.as_json
          }
        }
      )
    end

    specify { expect(response).to have_http_status :ok }
  end
end
