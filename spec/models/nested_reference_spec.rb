# coding: UTF-8
require 'spec_helper'

describe NestedReference do

  describe "validation" do
    before do
      @reference = NestedReference.new title: 'asdf', author_names: [Factory(:author_name)], citation_year: '2010',
        nested_reference: Factory(:reference), pages_in: 'Pp 2 in:'
    end
    it "should be valid with the attributes given above" do
      @reference.should be_valid
    end
    it "should not be valid without a nested reference" do
      @reference.nested_reference = nil
      @reference.should_not be_valid
    end
    it "should not be valid without a pages in" do
      @reference.pages_in = nil
      @reference.should_not be_valid
    end
    it "should refer to an existing reference" do
      @reference.nested_reference_id = 232434
      @reference.should_not be_valid
    end
    it "should not point to itself" do
      @reference.nested_reference_id = @reference.id
      @reference.should_not be_valid
    end
    it "should not point to something that points to itself" do
      inner_most = Factory :book_reference
      middle = Factory :nested_reference, nested_reference: inner_most
      top = Factory :nested_reference, nested_reference: middle 
      middle.nested_reference = top
      middle.should_not be_valid
    end
  end

  describe "deletion" do
    it "should not be possible to delete a nestee" do
      reference = NestedReference.create! title: 'asdf', author_names: [Factory(:author_name)], citation_year: '2010',
        nested_reference: Factory(:reference), pages_in: 'Pp 2 in:'
      reference.nested_reference.destroy.should be_false
    end

  end

end
