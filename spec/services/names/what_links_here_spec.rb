require "spec_helper"

describe Names::WhatLinksHere do
  describe "#call" do
    it "returns references in fields" do
      taxon = create :family
      protonym = create :protonym, name: taxon.name

      expect(described_class[taxon.name]).to match_array [
        TableRef.new('taxa', :name_id, taxon.id),
        TableRef.new('protonyms', :name_id, protonym.id)
      ]
    end
  end
end
