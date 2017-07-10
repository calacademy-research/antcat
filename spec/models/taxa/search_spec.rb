require 'spec_helper'

describe Taxa::Search do
  describe ".quick_search" do
    it "calls `Taxa::QuickSearch`" do
      expect(Taxa::QuickSearch).to receive(:new)
        .with("Atta", search_type: nil, valid_only: false).and_call_original
      described_class.quick_search "Atta"
    end
  end

  describe ".advanced_search" do
    it "calls `Taxa::AdvancedSearch`" do
      expect(Taxa::AdvancedSearch).to receive(:new).with({}).and_call_original
      described_class.advanced_search({})
    end
  end
end
