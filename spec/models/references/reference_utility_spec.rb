# coding: UTF-8
require 'spec_helper'

describe Reference do

  describe "replacing an author name" do
    it "should change the author name" do
      AuthorName.destroy_all
      author = Author.create!
      uppercase = AuthorName.create! :name => 'MacKay, W. P.', :author => author
      lowercase = AuthorName.create! :name => 'Mackay, W. P.', :author => author

      reference = FactoryGirl.create :reference, :author_names => [uppercase]
      expect(reference.author_names_string).to eq('MacKay, W. P.')

      reference.replace_author_name 'MacKay, W. P.', lowercase

      expect(reference.reload.author_names_string).to eq('Mackay, W. P.')
      expect(AuthorName.count).to eq(2)
    end
  end

  describe "importing PDF links" do
    it "should delegate to the right object" do
      mock = double Importers::Hol::DocumentUrlImporter
      expect(Importers::Hol::DocumentUrlImporter).to receive(:new).and_return mock
      expect(mock).to receive(:import)
      Reference.import_hol_document_urls
    end
  end

  describe "Replacement" do
    describe "Batch processing a number of replacements in one pass" do
      it "should replace all missing references" do
        missing_reference = FactoryGirl.create :missing_reference, citation: 'Borowiec, 2010'
        protonym = FactoryGirl.create :protonym, authorship: FactoryGirl.create(:citation, reference: missing_reference)
        taxon = create_genus protonym: protonym
        expect(taxon.protonym.authorship.reference).to eq(missing_reference)
        nonmissing_reference = FactoryGirl.create :article_reference, key_cache: 'Borowiec, 2010'

        Reference.replace_with_batch [{replace: missing_reference.id, with: nonmissing_reference.id}]

        expect(taxon.reload.protonym.authorship.reference).to eq(nonmissing_reference)
      end
      it "should replace references in taxt to the MissingReference to the found reference" do
        found_reference = FactoryGirl.create :article_reference
        missing_reference = FactoryGirl.create :missing_reference, citation: 'Borowiec, 2010'
        item = TaxonHistoryItem.create! taxt: "{ref #{missing_reference.id}}"
        Reference.replace_with_batch [{replace: missing_reference.id, with: found_reference.id}]
        expect(item.reload.taxt).to eq("{ref #{found_reference.id}}")
      end
      it "should replace references in citations" do
        found_reference = FactoryGirl.create :article_reference
        missing_reference = FactoryGirl.create :missing_reference, citation: 'Borowiec, 2010'
        citation = Citation.create! reference: missing_reference
        Reference.replace_with_batch [{replace: missing_reference.id, with: found_reference.id}]
        expect(citation.reload.reference).to eq(found_reference)
      end
    end
  end
end
