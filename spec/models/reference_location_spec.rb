# coding: UTF-8
require 'spec_helper'

describe ReferenceLocation do
  it "has a Reference" do
    reference = Factory :reference
    reference_location = ReferenceLocation.create! :reference => reference
    reference_location.reload.reference.should == reference
  end

  describe "Importing" do
    it "works" do
      reference = Factory :reference, :author_names => [Factory(:author_name, :name => 'Bolton')], :year => '1920'
      Reference.should_receive(:find_by_bolton_author_year).and_return reference
      reference_location = ReferenceLocation.import :author_names => ['Bolton'], :year => '1920', :pages => '23'
      reference_location.reload
      reference_location.pages.should == '23'
      reference_location.reference.should == reference
    end
  end

end
