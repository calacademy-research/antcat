# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::ReferencesController, as: :visitor do
  describe "GET index" do
    specify do
      reference = create :any_reference
      get :index
      expect(json_response).to eq([Api::V1::ReferenceSerializer.new(reference).as_json])
    end

    specify { expect(get(:index)).to have_http_status :ok }
  end

  describe "GET show" do
    let!(:reference) { create :any_reference, :with_notes }

    specify do
      get :show, params: { id: reference.id }
      expect(json_response).to eq Api::V1::ReferenceSerializer.new(reference).as_json
    end

    specify { expect(get(:show, params: { id: reference.id })).to have_http_status :ok }
  end
end
