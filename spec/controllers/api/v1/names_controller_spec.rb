# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::NamesController, as: :visitor do
  describe "GET index" do
    specify do
      name = create :family_name
      get :index
      expect(json_response).to eq([name.as_json])
    end

    specify { expect(get(:index)).to have_http_status :ok }
  end

  describe "GET show" do
    let!(:name) { create :family_name }

    specify do
      get :show, params: { id: name.id }
      expect(json_response).to eq(name.as_json) # TOOD: Lazy.
    end

    specify { expect(get(:show, params: { id: name.id })).to have_http_status :ok }
  end
end
