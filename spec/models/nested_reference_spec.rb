# coding: UTF-8
require 'spec_helper'

describe NestedReference do

  describe "Validation" do
    before do
      @reference = NestedReference.new :title => 'asdf', :author_names => [FactoryGirl.create(:author_name)], :citation_year => '2010',
        :nesting_reference => FactoryGirl.create(:reference), :pages_in => 'Pp 2 in:'
    end
    it "should be valid with the attributes given above" do
      @reference.should be_valid
    end
    it "should not be valid without a nesting_reference" do
      @reference.nesting_reference = nil
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
      @reference.nesting_reference_id = 232434
      @reference.should_not be_valid
    end
    it "should not point to itself" do
      @reference.nesting_reference_id = @reference.id
      @reference.should_not be_valid
    end
    it "should not point to something that points to itself" do
      inner_most = FactoryGirl.create :book_reference
      middle = FactoryGirl.create :nested_reference, :nesting_reference => inner_most
      top = FactoryGirl.create :nested_reference, :nesting_reference => middle
      middle.nesting_reference = top
      middle.should_not be_valid
    end
    it "can have a nesting_reference" do
      nesting_reference = FactoryGirl.create :reference
      nestee = FactoryGirl.create :nested_reference, nesting_reference: nesting_reference
      nestee.nesting_reference.should == nesting_reference
    end
  end

  describe "Deletion" do
    it "should not be possible to delete a nestee" do
      reference = NestedReference.create! :title => 'asdf', :author_names => [FactoryGirl.create(:author_name)], :citation_year => '2010',
        :nesting_reference => FactoryGirl.create(:reference), :pages_in => 'Pp 2 in:'
      reference.nesting_reference.destroy.should be_false
    end

  end

end
