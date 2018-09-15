require "spec_helper"

describe Autocomplete::AutocompleteReferences do
  describe "#format_autosuggest_keywords" do
    subject { described_class.new('dummy') }

    let!(:reference) { create :reference, author_name: 'E.O. Wilson' }

    it "replaces the typed author with the suggested author" do
      keyword_params = { author: "wil" }
      search_query = subject.send :format_autosuggest_keywords, reference, keyword_params
      expect(search_query).to eq "author:'E.O. Wilson'"
    end
  end
end
