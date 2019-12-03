require 'rails_helper'

describe Publishers::AutocompletesController do
  describe "GET show" do
    let(:term) { "wiley" }

    it "calls `Autocomplete::AutocompletePublishers`" do
      expect(Autocomplete::AutocompletePublishers).to receive(:new).with(term).and_call_original
      get :show, params: { term: term }
    end
  end
end
