# frozen_string_literal: true

require 'rails_helper'

describe Authors::ExtractAuthorNameParts do
  describe "#call" do
    it "returns an empty hash if the string is empty" do
      expect(described_class['']).to eq({})
      expect(described_class[nil]).to eq({})
    end

    it "simply returns the name if there's only one word" do
      expect(described_class['Bolton']).to eq last: 'Bolton'
    end

    it "separates the words if there are multiple" do
      expect(described_class['Bolton, B.L.']).to eq last: 'Bolton', first_and_initials: 'B.L.'
    end

    it "uses all words if there is no comma" do
      expect(described_class['Royal Academy']).to eq last: 'Royal Academy'
    end

    it "uses all words before the comma if there are multiple" do
      expect(described_class['Baroni Urbani, C.']).to eq last: 'Baroni Urbani', first_and_initials: 'C.'
    end
  end
end
