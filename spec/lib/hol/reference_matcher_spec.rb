require 'spec_helper'

describe Hol::ReferenceMatcher do
  before do
    @matcher = Hol::ReferenceMatcher.new
  end

  describe "No matching authors" do
    it "should return :no_entries_for_author" do
      mock_bibliography = mock 'Bibliography'
      Hol::Bibliography.stub!(:new).and_return mock_bibliography
      mock_bibliography.stub!(:read_references).and_return []
      reference = Factory.build :reference
      @matcher.match(reference).should == :no_entries_for_author
    end
  end

end
