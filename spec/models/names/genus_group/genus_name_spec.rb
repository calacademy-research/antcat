require 'spec_helper'

describe GenusName do
  describe "#genus_epithet" do
    subject { described_class.new name: 'Atta', epithet: 'Atta' }

    it "knows its genus name" do
      expect(subject.genus_epithet).to eq 'Atta'
    end
  end
end
