require 'rails_helper'

describe WikiPages::AutocompletesController do
  describe "GET show", as: :visitor do
    let(:q) { "help" }

    it "calls `Autocomplete::AutocompleteWikiPages`" do
      expect(Autocomplete::AutocompleteWikiPages).to receive(:new).with(q).and_call_original
      get :show, params: { q: q, format: :json }
    end
  end
end
