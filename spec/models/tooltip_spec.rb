require 'spec_helper'

describe Tooltip do
  it { is_expected.to be_versioned }

  describe "#key" do
    it { is_expected.to validate_uniqueness_of :key }
    it { is_expected.to validate_presence_of :key }
    it { is_expected.to validate_presence_of :scope }
    it { is_expected.to allow_value('name-space._key1:').for :key }
    it { is_expected.not_to allow_value('^namespace').for :key }
    it { is_expected.not_to allow_value('nämespace').for :key }
  end

  describe "scopes" do
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
