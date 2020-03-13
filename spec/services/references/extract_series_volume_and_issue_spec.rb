require 'rails_helper'

describe References::ExtractSeriesVolumeAndIssue do
  let(:reference) { create :article_reference }

  describe "#call" do
    it "can parse out volume and issue" do
      expect(described_class["92(32)"]).to eq volume: '92', issue: '32'
    end

    it "can parse out the series and volume" do
      expect(described_class["(10)8"]).to eq series: '10', volume: '8'
    end

    it "can parse out series, volume and issue" do
      expect(described_class['(I)C(xix)']). to eq series: 'I', volume: 'C', issue: 'xix'
    end
  end
end
