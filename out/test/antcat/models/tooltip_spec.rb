require 'spec_helper'

describe Tooltip, type: :model do

  describe "versioning", versioning: true do
    let!(:tooltip) { FactoryGirl.create :tooltip, key: "references.authors" }

    it 'keeps versions' do
      expect(tooltip.versions.last.event).to eq "create"
      tooltip.update_attributes! key: "oops.typo"
      expect(tooltip.versions.last.event).to eq "update"
      expect(tooltip).to have_a_version_with key: "references.authors"
    end
  end

  it { should validate_uniqueness_of(:key) }
  it { should validate_presence_of(:key) }
  it { should allow_value('name-space._key1:').for(:key) }
  it { should_not allow_value('^namespace').for(:key) }
  it { should_not allow_value('nämespace').for(:key) }

  describe "scopes" do
    describe "default scope" do
      let!(:z_tooltip) { FactoryGirl.create :tooltip, key: "zoo.message" }
      let!(:a_tooltip) { FactoryGirl.create :tooltip, key: "all.zoo.message" }
      let!(:b_tooltip) { FactoryGirl.create :tooltip, key: "books.message", key_enabled: false }

      it "orders by ascending name" do
        expect(Tooltip.all).to eq [a_tooltip, b_tooltip, z_tooltip]
      end
    end

    describe ".enabled_keys" do
      let!(:enabled) { FactoryGirl.create :tooltip, key_enabled: true }
      let!(:disabled) { FactoryGirl.create :tooltip, key_enabled: false }

      it "only returns enabled keys" do
        expect(Tooltip.enabled_keys).to eq [enabled]
      end
    end

    describe ".enabled_selectors" do
      let!(:enabled) { FactoryGirl.create :tooltip }
      let!(:disabled) { FactoryGirl.create :tooltip, selector_enabled: false }
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
