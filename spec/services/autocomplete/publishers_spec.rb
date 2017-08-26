require "spec_helper"

describe Autocomplete::Publishers do
  describe "#call" do
    it "fuzzy matches name/place combinations" do
      Publisher.create! name: 'Wiley', place: Place.create!(name: 'Chicago')
      Publisher.create! name: 'Wiley', place: Place.create!(name: 'Toronto')
      expect(described_class.new('chw').call).to eq ['Chicago: Wiley']
    end

    it "can find a match even if there's no place" do
      Publisher.create! name: 'Wiley'
      expect(described_class.new('w').call).to eq ['Wiley']
    end
  end
end
