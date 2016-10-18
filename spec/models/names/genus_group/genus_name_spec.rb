require 'spec_helper'

describe GenusName do
  describe "#genus_name" do
    it "knows its genus name" do
      name = GenusName.new name: 'Atta', epithet: 'Atta'
      expect(name.genus_name).to eq 'Atta'
    end
  end
end
