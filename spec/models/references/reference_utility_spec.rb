require 'spec_helper'

describe Reference do
  # Batch processing a number of replacements in one pass
  describe "#replace_with_batch" do
    let(:missing_reference) { create :missing_reference, citation: 'Borowiec, 2010' }
    let(:found_reference) { create :article_reference }

    it "replaces all missing references" do
      protonym = create :protonym, authorship: create(:citation, reference: missing_reference)
      taxon = create_genus protonym: protonym

      expect(taxon.protonym.authorship.reference).to eq missing_reference

      nonmissing_reference = create :article_reference, key_cache: 'Borowiec, 2010'

      Reference.replace_with_batch [{replace: missing_reference.id, with: nonmissing_reference.id}]
      expect(taxon.reload.protonym.authorship.reference).to eq nonmissing_reference
    end

    it "replaces references in taxt to the MissingReference to the found reference" do
      item = TaxonHistoryItem.create! taxt: "{ref #{missing_reference.id}}"

      Reference.replace_with_batch [{replace: missing_reference.id, with: found_reference.id}]
      expect(item.reload.taxt).to eq "{ref #{found_reference.id}}"
    end

    it "replaces references in citations" do
      citation = Citation.create! reference: missing_reference

      Reference.replace_with_batch [{replace: missing_reference.id, with: found_reference.id}]
      expect(citation.reload.reference).to eq found_reference
    end
  end
end
