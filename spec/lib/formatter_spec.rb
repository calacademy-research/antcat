# coding: UTF-8
require 'spec_helper'

describe Formatter do
  before do
    @formatter = CatalogFormatter
  end

  describe "Status labels" do
    it "should return the singular and the plural for a status" do
      @formatter.status_labels['synonym'][:singular].should == 'synonym'
      @formatter.status_labels['synonym'][:plural].should == 'synonyms'
    end
  end

  describe "Pluralizing with commas" do
    it "should handle a single item" do
      @formatter.pluralize_with_delimiters(1, 'bear').should == '1 bear'
    end
    it "should handle two items" do
      @formatter.pluralize_with_delimiters(2, 'bear').should == '2 bears'
    end
    it "should use the provided plural" do
      @formatter.pluralize_with_delimiters(2, 'genus', 'genera').should == '2 genera'
    end
    it "should use commas" do
      @formatter.pluralize_with_delimiters(2000, 'bear').should == '2,000 bears'
    end
  end

end
