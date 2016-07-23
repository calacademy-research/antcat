require 'spec_helper'

describe UnknownReference do
  it { should validate_presence_of(:year) }
  it { should validate_presence_of(:citation) }

  describe "validation" do
    before do
      author_name = create :author_name
      @reference = UnknownReference.new author_names: [author_name],
        title: 'Title', citation_year: '2010a', citation: 'Citation'
    end

    it "should be be valid the way I set it up" do
      expect(@reference).to be_valid
    end
  end

  describe "entering a newline in the citation" do
    it "strips the newline" do
      reference = create :unknown_reference
      reference.title = "A\nB"
      reference.citation = "A\nB"
      reference.save!

      expect(reference.title).to eq "A B"
      expect(reference.citation).to eq "A B"
    end
  end
end
