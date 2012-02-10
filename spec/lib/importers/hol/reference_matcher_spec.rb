# coding: UTF-8
require 'spec_helper'

describe Hol::ReferenceMatcher do
  before do
    @matcher = Hol::ReferenceMatcher.new
  end

  describe "No matching authors" do
    it "should return :no_entries_for_author" do
      Hol::Bibliography.stub!(:read_references).and_return []
      reference = Factory.build :reference
      @matcher.match(reference).should == :no_entries_for_author
    end
  end

  describe "Returning just one match" do
    it "should return the best match" do
      best_match = mock
      good_match = mock
      reference = Factory.build :article_reference
      Hol::Bibliography.stub!(:read_references).and_return [good_match, best_match]
      reference.should_receive(:<=>).with(best_match).and_return 0.9
      reference.should_receive(:<=>).with(good_match).and_return 0.8
      @matcher.match(reference).should == best_match
    end
  end

  describe "No match found, but matching author exists" do
    it "should return nil" do
      reference = Factory.build :article_reference
      hol_reference = Hol::Reference.new
      @matcher.stub!(:candidates_for).and_return [hol_reference]
      reference.stub(:<=>).and_return 0.0
      @matcher.match(reference).should be_nil
    end
  end

  describe "One match found" do
    it "should return that match" do
      reference = Factory.build :article_reference
      hol_reference = Hol::Reference.new
      @matcher.stub!(:candidates_for).and_return [hol_reference]
      reference.stub(:<=>).and_return 1.0
      @matcher.match(reference).should == hol_reference
    end
  end

  describe "Matching a book" do
    it "shouldn't" do
      reference = Factory.build :book_reference
      @matcher.match(reference).should == :book_reference
    end
  end

end
