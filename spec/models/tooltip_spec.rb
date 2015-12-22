require 'spec_helper'

describe Tooltip do

  describe "scopes" do
    describe "default scope" do
      let!(:z_tooltip) { FactoryGirl.create :tooltip, key: "zoo.message" }
      let!(:a_tooltip) { FactoryGirl.create :tooltip, key: "all.zoo.message" }
      let!(:b_tooltip) { FactoryGirl.create :tooltip, key: "books.message", enabled: false }

      it "orders by ascending name" do
        expect(Tooltip.all).to eq [a_tooltip, b_tooltip, z_tooltip]
      end
    end

    describe ".enabled" do
      let!(:enabled) {  FactoryGirl.create :tooltip }
      let!(:disabled) {  FactoryGirl.create :tooltip, enabled: false }

      it "only returns enabled" do
        expect(Tooltip.enabled).to eq [enabled]
      end
    end

    describe ".enabled_selectors" do
      let!(:enabled) { FactoryGirl.create :tooltip }
      let!(:disabled) { FactoryGirl.create :tooltip, enabled: false }
      let!(:selector_enabled) do
         FactoryGirl.create :tooltip, selector_enabled: true, selector: "#header"
      end
      let!(:selector_enabled_but_empty_selector) do
         FactoryGirl.create :tooltip, selector_enabled: true, selector: ""
      end

      it "only returns enabled selectors" do
        expect(Tooltip.enabled_selectors).to eq [selector_enabled]
      end

      it "handles nil" do
         FactoryGirl.create :tooltip, selector_enabled: true
        expect(Tooltip.enabled_selectors).to eq [selector_enabled]
      end
    end

  end
end
