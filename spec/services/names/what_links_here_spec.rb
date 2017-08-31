require "spec_helper"

describe Names::WhatLinksHere do
  describe "#call" do
    it "returns references in fields" do
      atta = create_genus 'Atta'
      protonym = create :protonym, name: atta.name
      atta.update_attribute :protonym, protonym
      atta.update_attribute :type_name, atta.name

      subject = described_class.new(atta.name)
      expect(subject.call).to match_array [
        { table: 'taxa', field: :name_id, id: atta.id },
        { table: 'taxa', field: :type_name_id, id: atta.id },
        { table: 'protonyms', field: :name_id, id: protonym.id }
      ]
    end

    it "returns references in taxts" do
      atta = create_genus 'Atta'
      eciton = create_genus 'Eciton'
      eciton.update_attribute :type_taxt, "{nam #{atta.name.id}}"

      subject = described_class.new(atta.name)
      expect(subject.call).to match_array [
        { table: 'taxa', field: :name_id, id: atta.id },
        { table: 'taxa', field: :type_taxt, id: eciton.id }
      ]
    end
  end

  describe "#references_in_taxt" do
    it "returns instances that reference this name" do
      name = Name.create! name: 'Atta'

      # Create an instance for each type of taxt.
      Taxt::TAXT_FIELDS.each do |klass, fields|
        fields.each { |field| create klass, field => "{nam #{name.id}}" }
      end

      # Count the total referencing items.
      refs = described_class.new(name).send(:references_in_taxt)
      expect(refs.size).to eq(
        Taxt::TAXT_FIELDS.map { |klass, fields| fields.size }.sum
      )

      # Count the total referencing items of each type.
      Taxt::TAXT_FIELDS.each do |klass, fields|
        fields.each do |field|
          expect(refs.select { |i| i[:table] == klass.table_name }.size).to eq(
            Taxt::TAXT_FIELDS.detect { |k, f| k == klass }[1].size
          )
        end
      end
    end
  end
end
