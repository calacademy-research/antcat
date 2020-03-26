# frozen_string_literal: true

require 'rails_helper'

describe PluralizeWithDelimiters do
  describe "#call" do
    it "handles single items" do
      expect(described_class[1, 'bear']).to eq '1 bear'
    end

    it "pluralizes" do
      expect(described_class[2, 'bear']).to eq '2 bears'
    end

    it "uses the provided plural" do
      expect(described_class[2, 'genus', 'genera']).to eq '2 genera'
    end

    it "uses commas" do
      expect(described_class[2000, 'bear']).to eq '2,000 bears'
    end
  end
end
