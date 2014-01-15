# coding: UTF-8
require 'spec_helper'

describe NestedReference do

  describe "validation" do
    before do
      @reference = NestedReference.new :title => 'asdf', :author_names => [FactoryGirl.create(:author_name)], :citation_year => '2010',
        :nester => FactoryGirl.create(:reference), :pages_in => 'Pp 2 in:'
    end
    it "should be valid with the attributes given above" do
      @reference.should be_valid
    end
    it "should not be valid without a nested reference" do
      @reference.nested_reference = nil
      @reference.should_not be_valid
    end
    it "should be valid without a title" do
      @reference.title = nil
      @reference.should be_valid
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
      inner_most = FactoryGirl.create :book_reference
      middle = FactoryGirl.create :nested_reference, :nested_reference => inner_most
      top = FactoryGirl.create :nested_reference, :nested_reference => middle
      middle.nested_reference = top
      middle.should_not be_valid
    end
    it "can have a nester" do
      nester = FactoryGirl.create :reference
      nestee = FactoryGirl.create :nested_reference, nested_reference: nester
      nestee.nester.should == nester
    end
  end

  describe "deletion" do
    it "should not be possible to delete a nestee" do
      reference = NestedReference.create! :title => 'asdf', :author_names => [FactoryGirl.create(:author_name)], :citation_year => '2010',
        :nested_reference => FactoryGirl.create(:reference), :pages_in => 'Pp 2 in:'
      reference.nested_reference.destroy.should be_false
    end

  end

  describe "Formatted reference cache" do
    describe "Invalidating the cache" do
      it "When the nester changes, it and the nestee should be invalidated" do
        nester = FactoryGirl.create :reference
        nestee = FactoryGirl.create :nested_reference, nested_reference: nester
        nester.title = 'title'
        nester.save!
        nester.reload.formatted_cache.should be_nil
        nestee.reload.formatted_cache.should be_nil
      end
      it "should invalidate the cache for the reference that uses the reference document" do
        nester = FactoryGirl.create :reference
        nestee = FactoryGirl.create :nested_reference, nested_reference: nester
        reference = FactoryGirl.create :article_reference
        reference_document = FactoryGirl.create :reference_document, reference: reference
        reference.populate_cache
        reference_document.invalidate_formatted_reference_cache
        reference.formatted_cache.should be_nil
      end
    end
  end

end
