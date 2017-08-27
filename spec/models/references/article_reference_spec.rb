require 'spec_helper'

describe ArticleReference do
  it { is_expected.to validate_presence_of :year }
  it { is_expected.to validate_presence_of :series_volume_issue }
  it { is_expected.to validate_presence_of :journal }

  let(:reference) { build_stubbed :article_reference }

  describe "parsing fields from series_volume_issue" do
    it "can extract volume and issue" do
      reference.series_volume_issue = "92(32)"
      expect(reference.volume).to eq '92'
      expect(reference.issue).to eq '32'
    end

    it "can extract the series and volume" do
      reference.series_volume_issue = '(10)8'
      expect(reference.series).to eq '10'
      expect(reference.volume).to eq '8'
    end

    it "can extract series, volume and issue" do
      reference.series_volume_issue = '(I)C(xix):129-131.'
      expect(reference.series).to eq 'I'
      expect(reference.volume).to eq 'C'
      expect(reference.issue).to eq 'xix'
    end
  end

  describe "parsing fields from pagination" do
    it "can extract beginning and ending page numbers" do
      reference.pagination = '163-181'
      expect(reference.start_page).to eq '163'
      expect(reference.end_page).to eq '181'
    end

    it "can extract single page numbers" do
      reference.pagination = "8"
      expect(reference.start_page).to eq '8'
      expect(reference.end_page).to be_nil
    end
  end
end
