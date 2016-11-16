require 'spec_helper'

describe MergeAuthorsHelper do
  describe "#conjuncted_list" do
    it "handles two items" do
      result = helper.conjuncted_list ['a', 'b'], 'item'
      expect(result).to eq %{<span class="item">a</span> and <span class="item">b</span>}
      expect(result).to be_html_safe
    end

    it "handles four items" do
      expect(helper.conjuncted_list(['a', 'b', 'c', 'd'], 'item')).to eq(
        %{<span class="item">a</span>, <span class="item">b</span>, <span class="item">c</span> and <span class="item">d</span>}
      )
    end

    it "escapes the items" do
      expect(helper.conjuncted_list(['<script>'], 'item'))
        .to eq %{<span class="item">&lt;script&gt;</span>}
    end
  end
end
