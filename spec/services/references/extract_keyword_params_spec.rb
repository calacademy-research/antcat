require "spec_helper"

describe References::ExtractKeywordParams do
  describe "#call" do
    it "doesn't modify the orginal search term" do
      q = "Bolton 2003"
      _ = described_class.new(q).call
      expect(q).to eq q
    end

    it "doesn't change the keywords unless keyword params are present" do
      q = "Bolton 2003"
      keyword_params = described_class.new(q).call
      expect(keyword_params[:keywords]).to eq q
    end

    it "modifies the keywords string after extraction" do
      keyword_params = described_class.new("Bolton year:2003").call
      expect(keyword_params[:keywords]).to eq "Bolton"
    end

    describe "year keywords" do
      it "extracts the year" do
        keyword_params = described_class.new("Bolton year:2003").call
        expect(keyword_params[:year]).to eq "2003"
      end

      it "extracts ranges of years" do
        keyword_params = described_class.new("Bolton year:2003-2015").call
        expect(keyword_params[:start_year]).to eq "2003"
        expect(keyword_params[:end_year]).to eq "2015"
      end
    end

    it "extracts reference types" do
      keyword_params = described_class.new("Bolton type:nested year:2003").call
      expect(keyword_params[:reference_type]).to eq :nested
    end

    it "extracts authors" do
      keyword_params = described_class.new("Ants Book author:Bolton").call
      expect(keyword_params[:author]).to eq "Bolton"
    end

    describe "author queries containing spaces" do
      it "handles double quotes" do
        keyword_params = described_class.new('Ants Book author:"Barry Bolton"').call
        expect(keyword_params[:author]).to eq "Barry Bolton"
      end

      it "handles single quotes" do
        keyword_params = described_class.new("Ants Book author:'Barry Bolton'").call
        expect(keyword_params[:author]).to eq "Barry Bolton"
      end
    end

    describe "author queries not wrapped in quotes" do
      it "handles hyphens" do
        keyword_params = described_class.new('author:Barry-Bolton').call
        expect(keyword_params[:author]).to eq "Barry-Bolton"
      end

      it "handles diacritics" do
        keyword_params = described_class.new("author:Hölldobler").call
        expect(keyword_params[:author]).to eq "Hölldobler"
      end

      it "doesn't break if more search term are added after the author keyword" do
        q = "author:Hölldobler random string"
        keyword_params = described_class.new(q).call
        expect(keyword_params[:author]).to eq "Hölldobler"
        expect(keyword_params[:keywords]).to eq "random string"
      end
    end

    it "handles multiple keyword params" do
      q = 'Ants Book author:"Barry Bolton" year:2003 type:missing'
      keyword_params = described_class.new(q).call
      expect(keyword_params[:author]).to eq "Barry Bolton"
      expect(keyword_params[:year]).to eq "2003"
      expect(keyword_params[:reference_type]).to eq :missing
      expect(keyword_params[:keywords]).to eq "Ants Book"
    end

    it "handles keyword params without a serach term" do
      keyword_params = described_class.new('year:2003').call
      expect(keyword_params[:year]).to eq "2003"
      expect(keyword_params[:keywords]).to eq ""
    end

    it "ignores a single space after the colon after a keyword" do
      keyword_params = described_class.new('author: Wilson').call
      expect(keyword_params[:author]).to eq "Wilson"
      expect(keyword_params[:keywords]).to eq ""
    end

    it "ignores capitalization of the keyword" do
      keyword_params = described_class.new('Author:Wilson').call
      expect(keyword_params[:author]).to eq "Wilson"
      expect(keyword_params[:keywords]).to eq ""
    end
  end
end
