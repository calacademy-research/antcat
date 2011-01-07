require 'spec_helper'

describe Bolton::GenusCatalog do
  before do
    @genus_catalog = Bolton::GenusCatalog.new
  end

  describe 'importing files' do
    it "should call #import_html with the contents of each one" do
      File.should_receive(:read).with('first_filename').and_return('first contents')
      File.should_receive(:read).with('second_filename').and_return('second contents')
      @genus_catalog.should_receive(:import_html).with('first contents')
      @genus_catalog.should_receive(:import_html).with('second contents')
      @genus_catalog.import_files ['first_filename', 'second_filename']
    end
  end

  describe 'importing html' do
    it "should call the parser for each <p> and save the result" do
      Bolton::GenusCatalogParser.should_receive(:parse).with('foo').and_return :genus => {:name => 'bar'}
      Bolton::GenusCatalogParser.should_receive(:parse).with('bar').and_return :genus => {:name => 'foo'}
      Genus.should_receive(:create!).with :name => 'bar'
      Genus.should_receive(:create!).with :name => 'foo'
      @genus_catalog.import_html '<html><p>foo</p><p>bar</p></html>'
    end

    it "should not save the result if it wasn't a genus" do
      Bolton::GenusCatalogParser.should_receive(:parse).with('foo').and_return nil
      Genus.should_not_receive :create!
      @genus_catalog.import_html '<html><p>foo</p></html>'
    end
  end

end
