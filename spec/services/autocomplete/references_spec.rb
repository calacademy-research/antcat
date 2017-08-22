require "spec_helper"

describe Autocomplete::References do
  describe "#format_autosuggest_keywords" do
    let!(:reference) { reference_factory author_name: 'E.O. Wilson' }

    subject { described_class.new('dummy') }

    it "replaces the typed author with the suggested author" do
      keyword_params = { author: "wil" }
      search_query = subject.send :format_autosuggest_keywords, reference, keyword_params
      expect(search_query).to eq "author:'E.O. Wilson'"
    end
  end
end
