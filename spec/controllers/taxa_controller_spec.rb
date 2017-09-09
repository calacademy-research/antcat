require 'spec_helper'

describe TaxaController do
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
