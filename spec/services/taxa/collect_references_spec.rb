require 'rails_helper'

describe Taxa::CollectReferences do
  describe "#call" do
    let!(:taxon) { create :family }
    let!(:reference_1) { create :article_reference }
    let!(:reference_2) { create :article_reference }

    before do
      create :taxon_history_item, taxon: taxon, taxt: "see {ref #{reference_1.id}}"
      create :reference_section, taxon: taxon, references_taxt: "see {ref #{reference_2.id}}"
    end

    it 'collects references from various sources' do
      expect(described_class[taxon]).to match_array [taxon.authorship_reference, reference_1, reference_2]
    end
  end
end
