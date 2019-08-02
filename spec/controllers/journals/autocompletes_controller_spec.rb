require 'spec_helper'

describe Journals::AutocompletesController do
  describe "GET show" do
    let(:term) { "zootaxa" }

    it "calls `Autocomplete::AutocompleteJournals`" do
      expect(Autocomplete::AutocompleteJournals).to receive(:new).with(term).and_call_original
      get :show, params: { term: term, format: :json }
    end
  end
end
