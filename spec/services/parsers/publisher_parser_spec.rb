require 'spec_helper'

describe Parsers::PublisherParser do
  subject(:parser) { described_class }

  describe "getting the place and name" do
    it "returns nil if the string is unparseable" do
      expect(parser.parse('New York')).to be_nil
    end

    it "parses it correctly" do
      expect(parser.parse('New York: Houghton Mifflin')).
        to eq publisher: { name: 'Houghton Mifflin', place_name: 'New York' }
    end

    it "doesn't consider a single digit as a place ..." do
      expect(parser.parse('5: Rest')).to be_nil
    end

    it "... or two letters ..." do
      expect(parser.parse('Ab: Rest')).to be_nil
    end

    it "... or even three letters" do
      expect(parser.parse('Abc: Rest')).not_to be_nil
    end
  end
end
