require 'spec_helper'

describe Protonyms::AutocompletesController do
  describe "GET show" do
    let(:qq) { "lasius" }

    it "calls `Autocomplete::AutocompleteProtonyms`" do
      expect(Autocomplete::AutocompleteProtonyms).to receive(:new).with(qq).and_call_original
      get :show, params: { qq: qq, format: :json }
    end
  end
end
