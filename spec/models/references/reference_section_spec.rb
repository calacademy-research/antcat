# coding: UTF-8
require 'spec_helper'

describe ReferenceSection do

  describe "Deduping" do
    it "should destroy duplicate reference section" do
      taxon = create_genus
      taxon.reference_sections.create references_taxt: 'Taxt', position: 2
      taxon.reference_sections.create references_taxt: 'Taxt', position: 1
      taxon.reference_sections.create references_taxt: 'Not taxt', position: 3
      taxon.reload

      expect(taxon.reference_sections.count).to eq(3)

      ReferenceSection.dedupe

      taxon.reload
      expect(taxon.reference_sections.count).to eq(2)
      expect(taxon.reference_sections.map do |reference_section|
        [reference_section.position, reference_section.references_taxt]
      end).to match_array([[1, 'Taxt'], [3, 'Not taxt']])
    end
  end

  describe "Versioning" do
    it "should record versions" do
      with_versioning do
        reference_section = FactoryGirl.create :reference_section
        expect(reference_section.versions.last.event).to eq('create')
      end
    end
  end

end

