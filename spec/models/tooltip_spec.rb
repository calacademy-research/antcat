require 'spec_helper'

describe Tooltip do
  it { should be_versioned }

  describe "#key" do
    it { should validate_uniqueness_of :key }
    it { should validate_presence_of :key }
    it { should allow_value('name-space._key1:').for :key }
    it { should_not allow_value('^namespace').for :key }
    it { should_not allow_value('nämespace').for :key }
  end

  describe "scopes" do
    describe ".enabled_keys" do
      let!(:enabled) { create :tooltip, key_enabled: true }
      let!(:disabled) { create :tooltip, key_enabled: false }

      it "only returns enabled keys" do
        expect(described_class.enabled_keys).to eq [enabled]
      end
    end

    describe ".enabled_selectors" do
      let!(:enabled) { create :tooltip }
      let!(:disabled) { create :tooltip, selector_enabled: false }
      let!(:selector_enabled) do
        create :tooltip, selector_enabled: true, selector: "#header"
      end
      let!(:selector_enabled_but_empty_selector) do
        create :tooltip, selector_enabled: true, selector: ""
      end

      it "only returns enabled selectors" do
        expect(described_class.enabled_selectors).to eq [selector_enabled]
      end

      it "handles nil" do
        create :tooltip, selector_enabled: true
        expect(described_class.enabled_selectors).to eq [selector_enabled]
      end
    end
  end
end
