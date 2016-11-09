require 'spec_helper'

describe GenusName do
  describe "#genus_name" do
    let(:name) { GenusName.new name: 'Atta', epithet: 'Atta' }

    it "knows its genus name" do
      expect(name.genus_name).to eq 'Atta'
    end
  end
end
