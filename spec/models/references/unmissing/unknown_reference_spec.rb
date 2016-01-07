require 'spec_helper'

describe UnknownReference do

  describe "validation" do
    before do
      author_name = FactoryGirl.create :author_name
      @reference = UnknownReference.new :author_names => [author_name], :title => 'Title', :citation_year => '2010a',
        :citation => 'Citation'
    end
    it "should be be valid the way I set it up" do
      expect(@reference).to be_valid
    end
    it "should be not be valid without a citation" do
      @reference.citation = nil
      expect(@reference).not_to be_valid
    end
  end

  describe "entering a newline in the citation" do
    it "should strip the newline" do
      reference = FactoryGirl.create :unknown_reference
      reference.title = "A\nB"
      reference.citation = "A\nB"
      reference.save!
      expect(reference.title).to eq("A B")
      expect(reference.citation).to eq("A B")
    end
  end

end
