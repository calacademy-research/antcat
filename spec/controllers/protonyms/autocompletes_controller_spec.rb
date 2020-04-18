# frozen_string_literal: true

require 'rails_helper'

describe Protonyms::AutocompletesController do
  describe "GET show", as: :visitor do
    let(:qq) { "lasius" }

    it "calls `Autocomplete::ProtonymsQuery`" do
      expect(Autocomplete::ProtonymsQuery).to receive(:new).with(qq).and_call_original
      get :show, params: { qq: qq, format: :json }
    end
  end
end
