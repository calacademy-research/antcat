# frozen_string_literal: true

require 'rails_helper'

describe References::LinkableAutocompletesController do
  describe "GET show", as: :visitor do
    let(:q) { "bolton" }

    it "calls `Autocomplete::AutocompleteLinkableReferences`" do
      expect(Autocomplete::AutocompleteLinkableReferences).to receive(:new).with(q).and_call_original
      get :show, params: { q: q, format: :json }
    end
  end
end
