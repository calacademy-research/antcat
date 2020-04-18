# frozen_string_literal: true

require 'rails_helper'

describe Authors::AutocompletesController do
  describe "GET show", as: :visitor do
    let(:term) { "bolton" }

    it "calls `Autocomplete::AuthorNamesQuery`" do
      expect(Autocomplete::AuthorNamesQuery).to receive(:new).with(term).and_call_original
      get :show, params: { term: term, format: :json }
    end
  end
end
