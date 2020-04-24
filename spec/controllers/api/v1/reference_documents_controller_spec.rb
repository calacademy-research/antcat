# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::ReferenceDocumentsController, as: :visitor do
  describe "GET index" do
    specify do
      reference_document = create :reference_document
      get :index
      expect(json_response).to eq([reference_document.as_json(root: true)])
    end

    specify { expect(get(:index)).to have_http_status :ok }
  end

  describe "GET show" do
    let!(:reference_document) { create :reference_document }

    specify do
      get :show, params: { id: reference_document.id }
      expect(json_response).to eq(
        {
          "reference_document" => {
            "id" => reference_document.id,
            "reference_id" => reference_document.reference_id,
            "file_file_name" => reference_document.file_file_name,
            "url" => reference_document.url,
            "public" => reference_document.public,
            "created_at" => reference_document.created_at.as_json,
            "updated_at" => reference_document.updated_at.as_json
          }
        }
      )
    end

    specify { expect(get(:show, params: { id: reference_document.id })).to have_http_status :ok }
  end
end
