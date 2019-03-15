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

    it "returns references in taxts" do
      taxon = create :family
      other_taxon = create :family, type_taxt: "{nam #{taxon.name.id}}"

      subject = described_class.new(taxon.name)
      expect(subject.call).to match_array [
        { table: 'taxa', field: :name_id, id: taxon.id },
        { table: 'taxa', field: :type_taxt, id: other_taxon.id }
      ]
    end
  end

  describe "#references_in_taxt" do
    let(:name) { create :genus_name }

    before do
      # Create a record for each type of taxt.
      contrete_taxt_fields.each do |klass, fields|
        fields.each { |field| create klass.name.underscore.to_sym, field => "{nam #{name.id}}" }
      end
    end

    it "returns instances that reference this name" do
      refs = described_class.new(name).send(:references_in_taxt)

      # Count the total referencing items.
      expect(refs.size).to eq(taxt_fields.map { |_klass, fields| fields.size }.sum)

      # Count the total referencing items of each type.
      taxt_fields.each do |klass, fields|
        fields.each do |_field|
          expect(refs.select { |i| i[:table] == klass.table_name }.size).to eq(
            taxt_fields.detect { |k, _f| k == klass }[1].size
          )
        end
      end
    end
  end

  def taxt_fields
    [
      [Taxon, [:type_taxt, :headline_notes_taxt, :genus_species_header_notes_taxt]],
      [Citation, [:notes_taxt]],
      [ReferenceSection, [:title_taxt, :subtitle_taxt, :references_taxt]],
      [TaxonHistoryItem, [:taxt]]
    ]
  end

  # To replace the "non-concrete" `Taxon` with `Family`.
  def contrete_taxt_fields
    taxt_fields.tap { |array| array[0][0] = Family }
  end
end
