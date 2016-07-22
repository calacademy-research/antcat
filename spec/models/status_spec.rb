require 'spec_helper'

describe Status do

  describe "Status labels" do
    it "should return the singular and the plural for a status" do
      expect(Status['synonym'].to_s).to eq 'synonym'
      expect(Status['synonym'].to_s(:plural)).to eq 'synonyms'
    end
  end

  describe "Select box options" do
    it "should include 'valid'" do
      expect(Status.options_for_select.map(&:first).include?('valid')).to be_truthy
    end

    it "should not include 'nonsense'" do
      expect(Status.options_for_select.map(&:first).include?('nonsense')).to be_falsey
    end
  end

end
