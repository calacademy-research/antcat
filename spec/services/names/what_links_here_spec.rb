require "spec_helper"

describe Names::WhatLinksHere do
  describe "#call" do
    it "returns references in fields" do
      taxon = create :family
      protonym = create :protonym, name: taxon.name

      subject = described_class.new(taxon.name)
      expect(subject.call).to match_array [
        { table: 'taxa', field: :name_id, id: taxon.id },
        { table: 'protonyms', field: :name_id, id: protonym.id }
      ]
    end
  end
end
