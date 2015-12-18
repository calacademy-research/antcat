require 'spec_helper'

# TODO create tooltip factory
describe Tooltip do

  describe "scopes" do
    describe "default scope" do
      let!(:z_tooltip) { Tooltip.create!(key: "zoo.message") }
      let!(:a_tooltip) { Tooltip.create!(key: "all.zoo.message") }
      let!(:b_tooltip) { Tooltip.create!(key: "books.message", enabled: false) }

      it "orders by ascending name" do
        expect(Tooltip.all).to eq [a_tooltip, b_tooltip, z_tooltip]
      end
    end

    describe ".enabled" do
      let!(:enabled) { Tooltip.create!(key: "a") }
      let!(:disabled) { Tooltip.create!(key: "b", enabled: false) }

      it "only returns enabled" do
        expect(Tooltip.enabled).to eq [enabled]
      end
    end

    describe ".enabled_selectors" do
      let!(:enabled) { Tooltip.create!(key: "a") }
      let!(:disabled) { Tooltip.create!(key: "b", enabled: false) }
      let!(:selector_enabled) do
        Tooltip.create!(key: "c", selector_enabled: true, selector: "#header")
      end
      let!(:selector_enabled_but_empty_selector) do
        Tooltip.create!(key: "d", selector_enabled: true, selector: "")
      end

      it "only returns enabled selectors" do
        expect(Tooltip.enabled_selectors).to eq [selector_enabled]
      end

      it "handles nil" do
        Tooltip.create!(key: "e", selector_enabled: true)
        expect(Tooltip.enabled_selectors).to eq [selector_enabled]
      end
    end

  end
end
