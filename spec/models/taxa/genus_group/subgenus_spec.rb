require 'spec_helper'

describe Subgenus do
  let(:colobopsis) { create :subgenus, name: create(:name, name: 'Colobopsis') }

  it "must have a genus" do
    expect(colobopsis).to be_valid

    colobopsis.genus = nil
    expect(colobopsis).not_to be_valid

    colobopsis.genus = create :genus, name: create(:name, name: 'Camponotus')
    colobopsis.save!
    expect(colobopsis.reload.genus.name.to_s).to eq 'Camponotus'
  end

  describe "#statistics" do
    it "should have none" do
      expect(colobopsis.statistics).to be_nil
    end
  end
end
