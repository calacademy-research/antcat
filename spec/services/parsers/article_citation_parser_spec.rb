require 'spec_helper'

describe Parsers::ArticleCitationParser do
  subject(:parser) { described_class }

  describe "#get_series_volume_issue_parts" do
    it "can parse out volume and issue" do
      expect(parser.get_series_volume_issue_parts("92(32)")).
        to eq volume: '92', issue: '32'
    end

    it "can parse out the series and volume" do
      expect(parser.get_series_volume_issue_parts("(10)8")).
        to eq series: '10', volume: '8'
    end

    it "can parse out series, volume and issue" do
      expect(parser.get_series_volume_issue_parts('(I)C(xix)')).
        to eq series: 'I', volume: 'C', issue: 'xix'
    end
  end

  describe "#get_page_parts" do
    it "can parse beginning and ending page numbers" do
      expect(parser.get_page_parts('163-181')).to eq start: '163', end: '181'
    end

    it "can parse just a single page number" do
      expect(parser.get_page_parts('8')).to eq start: '8'
    end
  end
end
