require 'spec_helper'

describe GenusName do
  describe "#genus_name" do
    let(:name) { GenusName.new name: 'Atta', epithet: 'Atta' }

    it "knows its genus name" do
      expect(name.genus_name).to eq 'Atta'
    end
  end

  describe "indexing" do
    it "genus names works as expected" do
      name = GenusName.new name: 'Acus', epithet: 'Acus', epithets: nil
      name_split = name.to_s.split

      expect(name_split[0]).to eq 'Acus'
      expect(name_split[1]).to be_nil
      expect(name_split[2]).to be_nil
      expect(name_split[3]).to be_nil
    end
  end
end
