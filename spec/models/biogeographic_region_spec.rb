require 'spec_helper'

describe BiogeographicRegion do

  describe "Instances" do
    it "should have 'em" do
      instances = BiogeographicRegion.instances
      expect(instances).to be_kind_of Array
      expect(instances.size).not_to be_zero
      expect(instances.first.value).to eq('Nearctic')
      expect(instances.first.label).to eq('Nearctic')
    end
  end

  describe "Select options" do
    it "should include the null entry" do
      options_for_select = BiogeographicRegion.options_for_select
      expect(options_for_select.first).to eq([nil, nil])
    end
  end

end
