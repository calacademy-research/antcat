require 'spec_helper'

describe Parsers::ArticleCitationParser do
  describe ".get_series_volume_issue_parts" do
    it "can parse out volume and issue" do
      expect(described_class.get_series_volume_issue_parts("92(32)")).
        to eq volume: '92', issue: '32'
    end

    it "can parse out the series and volume" do
      expect(described_class.get_series_volume_issue_parts("(10)8")).
        to eq series: '10', volume: '8'
    end

    it "can parse out series, volume and issue" do
      expect(described_class.get_series_volume_issue_parts('(I)C(xix)')).
        to eq series: 'I', volume: 'C', issue: 'xix'
    end
  end
end
