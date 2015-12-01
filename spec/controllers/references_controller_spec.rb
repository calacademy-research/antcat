require 'spec_helper'

describe ReferencesController do
  before do
    @controller = ReferencesController.new
  end

  describe "autocompleting" do
    describe "#format_autosuggest_keywords" do
      it "replaces the typed author with the suggested author" do
        reference = reference_factory author_name: 'E.O. Wilson'
        keyword_params = { author: "wil" }
        search_query = @controller.send :format_autosuggest_keywords, reference, keyword_params
        expect(search_query).to eq "author:'E.O. Wilson'"
      end
    end
  end

end
