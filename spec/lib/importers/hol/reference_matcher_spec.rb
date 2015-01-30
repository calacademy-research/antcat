# coding: UTF-8
require 'spec_helper'

describe Importers::Hol::ReferenceMatcher do
  before do
    @matcher = Importers::Hol::ReferenceMatcher.new
  end

  describe "No matching authors" do
    it "should return :no_entries_for_author" do
      allow(Importers::Hol::Bibliography).to receive(:read_references).and_return []
      reference = FactoryGirl.build :reference
      expect(@matcher.match(reference)).to eq(:no_entries_for_author)
    end
  end

  describe "Returning just one match" do
    it "should return the best match" do
      best_match = double
      good_match = double
      reference = FactoryGirl.build :article_reference
      allow(Importers::Hol::Bibliography).to receive(:read_references).and_return [good_match, best_match]
      expect(reference).to receive(:<=>).with(best_match).and_return 0.9
      expect(reference).to receive(:<=>).with(good_match).and_return 0.8
      expect(@matcher.match(reference)).to eq(best_match)
    end
  end

  describe "No match found, but matching author exists" do
    it "should return nil" do
      reference = FactoryGirl.build :article_reference
      hol_reference = Hol::Reference.new
      allow(@matcher).to receive(:candidates_for).and_return [hol_reference]
      allow(reference).to receive(:<=>).and_return 0.0
      expect(@matcher.match(reference)).to be_nil
    end
  end

  describe "One match found" do
    it "should return that match" do
      reference = FactoryGirl.build :article_reference
      hol_reference = Hol::Reference.new
      allow(@matcher).to receive(:candidates_for).and_return [hol_reference]
      allow(reference).to receive(:<=>).and_return 1.0
      expect(@matcher.match(reference)).to eq(hol_reference)
    end
  end

  describe "Matching a book" do
    it "shouldn't" do
      reference = FactoryGirl.build :book_reference
      expect(@matcher.match(reference)).to eq(:book_reference)
    end
  end

end
