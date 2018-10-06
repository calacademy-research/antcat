require 'spec_helper'

describe AdvancedSearchPresenter::HTML do
  subject(:formatter) { described_class.new }

  describe "#format" do
    it "formats a taxon" do
      taxon = create :genus, incertae_sedis_in: 'genus', nomen_nudum: true

      results = formatter.format_status_reference(taxon)
      expect(results).to eq "<i>incertae sedis</i> in genus, <i>nomen nudum</i>"

      results = formatter.format_type_localities(taxon)
      expect(results).to eq ""
    end
  end
end
