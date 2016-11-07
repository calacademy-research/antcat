require 'spec_helper'

describe MissingReference do
  describe "Replacing" do
    # Replacing one missing reference
    describe "#replace_with" do
      let(:found_reference) { create :article_reference }
      let(:missing_reference) { create :missing_reference }

      it "replaces references in taxt to the MissingReference to the found reference" do
        item = TaxonHistoryItem.create! taxt: "{ref #{missing_reference.id}}"
        missing_reference.replace_with found_reference
        expect(item.reload.taxt).to eq "{ref #{found_reference.id}}"
      end

      it "doesn't save records that don't contain the {ref}" do
        item = TaxonHistoryItem.create! taxt: "Just some taxt"
        item.reload
        updated_at = item.updated_at
        missing_reference.replace_with found_reference
        item.reload
        expect(item.updated_at).to eq updated_at
      end

      it "replaces references in citations" do
        citation = Citation.create! reference: missing_reference
        missing_reference.replace_with found_reference
        expect(citation.reload.reference).to eq found_reference
      end
    end

    # Replacing all occurences of a citation with another reference
    describe ".replace_citation" do
      def missing_reference_with_taxt
        reference = create :missing_reference, citation: 'Citation'
        TaxonHistoryItem.create! taxt: "{ref #{reference.id}}"
      end

      let!(:first_citation_occurrence) { missing_reference_with_taxt }
      let!(:second_citation_occurrence) { missing_reference_with_taxt }
      let(:nonmissing_reference) { create :article_reference }

      it "replaces both missing references with the same citation" do
        MissingReference.replace_citation 'Citation', nonmissing_reference

        expect(first_citation_occurrence.reload.taxt).to eq "{ref #{nonmissing_reference.id}}"
        expect(second_citation_occurrence.reload.taxt).to eq "{ref #{nonmissing_reference.id}}"
      end
    end
  end

  describe "Optional year" do
    it "permits a missing year (unlike other references)" do
      reference = MissingReference.new title: 'missing', citation: 'Bolton'
      expect(reference).to be_valid
    end
  end

  describe "#keey" do
    it "has its own kind of decorator" do
      reference = create :missing_reference
      expect(reference.decorate).to be_kind_of MissingReferenceDecorator
    end
  end
end
