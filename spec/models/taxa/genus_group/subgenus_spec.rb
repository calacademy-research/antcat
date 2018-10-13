require 'spec_helper'

describe Subgenus do
  it { is_expected.to validate_presence_of :genus }

  describe "#statistics" do
    let(:subgenus) { create :subgenus }

    it "has none" do
      expect(subgenus.statistics).to be_nil
    end
  end
end
