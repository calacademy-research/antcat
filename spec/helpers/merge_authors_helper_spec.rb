require 'spec_helper'

describe MergeAuthorsHelper do
  describe "#author_names_sentence" do
    it "handles a single item" do
      result = helper.author_names_sentence ['a']
      expect(result).to eq %{<span>a</span>}
      expect(result).to be_html_safe
    end

    it "handles two items" do
      expect(helper.author_names_sentence(['a', 'b']))
        .to eq "<span>a</span> and <span>b</span>"
    end

    it "handles four items" do
      expect(helper.author_names_sentence(['a', 'b', 'c', 'd'])).to eq(
        "<span>a</span>, <span>b</span>, <span>c</span>, and <span>d</span>"
      )
    end

    it "escapes the items" do
      expect(helper.author_names_sentence(['<script>']))
        .to eq "<span>&lt;script&gt;</span>"
    end
  end
end
