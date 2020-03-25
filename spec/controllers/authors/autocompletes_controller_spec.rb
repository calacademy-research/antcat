require 'rails_helper'

describe Authors::AutocompletesController do
  describe "GET show", as: :visitor do
    let(:term) { "bolton" }

    it "calls `Autocomplete::AutocompleteAuthorNames`" do
      expect(Autocomplete::AutocompleteAuthorNames).to receive(:new).with(term).and_call_original
      get :show, params: { term: term, format: :json }
    end
  end
end
