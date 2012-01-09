# coding: UTF-8
require 'spec_helper'

require 'reference_utility'

describe Reference do

  describe "replacing an author name" do
    it "should change the author name" do
      AuthorName.destroy_all
      author = Author.create!
      uppercase = AuthorName.create! :name => 'MacKay, W. P.', :author => author
      lowercase = AuthorName.create! :name => 'Mackay, W. P.', :author => author

      reference = Factory :reference, :author_names => [uppercase]
      reference.author_names_string.should == 'MacKay, W. P.'

      reference.replace_author_name 'MacKay, W. P.', lowercase

      reference.reload.author_names_string.should == 'Mackay, W. P.'
      AuthorName.count.should == 2
    end
  end

  describe "importing PDF links" do
    it "should delegate to the right object" do
      mock = mock Hol::DocumentUrlImporter
      Hol::DocumentUrlImporter.should_receive(:new).and_return mock
      mock.should_receive(:import)
      Reference.import_hol_document_urls
    end
  end

end
