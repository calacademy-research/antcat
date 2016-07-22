require 'spec_helper'

describe TaxaController do
  before do
    @controller = TaxaController.new
  end

  describe "autocompleting" do
    describe "#format_autosuggest_keywords" do
      it "replaces the typed author with the suggested author" do
        atta = create_genus 'Atta'
        attacus = create_genus 'Attacus'
        ratta = create_genus 'Ratta'
        nylanderia = create_genus 'Nylanderia'

        get :autocomplete, q: "att", format: :json
        json = JSON.parse response.body

        returned_search_queries = json.map { |taxon| taxon["search_query"] }.sort
        expected_search_queries = [atta, attacus, ratta].map(&:name_cache).sort

        expect(returned_search_queries).to eq expected_search_queries
        expect(returned_search_queries).to_not include nylanderia.name_cache
      end
    end
  end

  describe "#build_relationships" do
    it "builds" do
      taxon = controller.send :build_new_taxon, :species
      expect(taxon.name).not_to be_blank
      expect(taxon.type_name).not_to be_blank
      expect(taxon.protonym).not_to be_blank
      expect(taxon.protonym.name).not_to be_blank
      expect(taxon.protonym.authorship).not_to be_blank
    end
  end
end
