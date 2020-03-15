require 'rails_helper'

describe Autocomplete::AutocompleteReferences do
  describe "#format_autosuggest_keywords" do
    let(:service) { described_class.new('dummy') }
    let!(:reference) { create :reference, author_name: 'E.O. Wilson' }

    # TODO: Refactor spec and code.
    it "replaces the typed author with the suggested author" do
      keyword_params = { author: "wil" }
      search_query = service.__send__ :format_autosuggest_keywords, reference, keyword_params
      expect(search_query).to eq "author:'E.O. Wilson'"
    end
  end
end
