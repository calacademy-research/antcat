require 'spec_helper'

describe Subgenus do
  it { is_expected.to validate_presence_of :genus }

  describe "#statistics" do
    let(:colobopsis) { create :subgenus, name: create(:name, name: 'Colobopsis') }

    it "has none" do
      expect(colobopsis.statistics).to be_nil
    end
  end
end
