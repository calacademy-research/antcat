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
      reference.author_names_string.should == 'MacKay, W. P.'

      reference.replace_author_name 'MacKay, W. P.', lowercase

      reference.reload.author_names_string.should == 'Mackay, W. P.'
      AuthorName.count.should == 2
    end
  end

  describe "importing PDF links" do
    it "should delegate to the right object" do
      mock = double Importers::Hol::DocumentUrlImporter
      Importers::Hol::DocumentUrlImporter.should_receive(:new).and_return mock
      mock.should_receive(:import)
      Reference.import_hol_document_urls
    end
  end

  describe "when a MissingReference is found" do
    before do
      @found_reference = FactoryGirl.create :article_reference
      @missing_reference = FactoryGirl.create :missing_reference
    end
    it "should replace references in taxt to the MissingReference to the found reference" do
      item = TaxonHistoryItem.create! taxt: "{ref #{@missing_reference.id}}"
      @missing_reference.replace_with @found_reference
      item.reload.taxt.should == "{ref #{@found_reference.id}}"
    end
    it "should not save records that don't contain the {ref}" do
      item = TaxonHistoryItem.create! taxt: "Just some taxt"
      item.reload
      updated_at = item.updated_at
      @missing_reference.replace_with @found_reference
      item.reload
      item.updated_at.should == updated_at
    end
    it "should replace references in citations" do
      citation = Citation.create! reference: @missing_reference
      @missing_reference.replace_with @found_reference
      citation.reload.reference.should == @found_reference
    end

    describe "Batch processing a number of replacements in one pass" do
      it "should replace references in taxt to the MissingReference to the found reference" do
        item = TaxonHistoryItem.create! taxt: "{ref #{@missing_reference.id}}"
        Reference.replace_with_batch [{replace: @missing_reference, with: @found_reference}]
        item.reload.taxt.should == "{ref #{@found_reference.id}}"
      end
      it "should replace references in citations" do
        citation = Citation.create! reference: @missing_reference
        Reference.replace_with_batch [{replace: @missing_reference, with: @found_reference}]
        citation.reload.reference.should == @found_reference
      end

    end
  end
end
