require 'spec_helper'

describe PublishersController do
  describe "GET autocomplete" do
    let(:term) { "wiley" }

    it "calls `Autocomplete::AutocompletePublishers`" do
      expect(Autocomplete::AutocompletePublishers).to receive(:new).with(term).and_call_original
      get :autocomplete, params: { term: term }
    end
  end
end
