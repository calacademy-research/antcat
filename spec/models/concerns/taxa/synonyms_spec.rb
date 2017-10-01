require "spec_helper"

describe Taxon do
  let(:taxon) { create_species }

  describe "#junior_synonyms_recursive" do
    context "when there are no `junior_synonyms`" do
      specify { expect(taxon.junior_synonyms_recursive).to be_empty }
    end

    context "when there are direct junior_synonyms" do
      let(:junior_synonym) { create_species }
      let(:another_junior_synonym) { create_species }

      before do
        Synonym.create! senior_synonym: taxon, junior_synonym: junior_synonym
        Synonym.create! senior_synonym: taxon, junior_synonym: another_junior_synonym
      end

      specify do
        expect(taxon.junior_synonyms_recursive).to eq [junior_synonym, another_junior_synonym]
      end
    end

    context "when there are nested `junior_synonyms`" do
      let(:junior_synonym) { create_species }
      let(:nested_junior_synonym) { create_species }
      let(:deeply_nested_junior_synonym) { create_species }
      let(:another_deeply_nested_junior_synonym) { create_species }

      before do
        Synonym.create! senior_synonym: taxon, junior_synonym: junior_synonym
        Synonym.create! senior_synonym: junior_synonym, junior_synonym: nested_junior_synonym
        Synonym.create! senior_synonym: nested_junior_synonym, junior_synonym: deeply_nested_junior_synonym
        Synonym.create! senior_synonym: nested_junior_synonym, junior_synonym: another_deeply_nested_junior_synonym
      end

      specify do
        expect(taxon.junior_synonyms_recursive).to eq [
          junior_synonym,
          nested_junior_synonym,
          deeply_nested_junior_synonym,
          another_deeply_nested_junior_synonym
        ]
      end
    end
  end
end
