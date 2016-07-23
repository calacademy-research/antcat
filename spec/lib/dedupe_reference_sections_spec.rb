require 'spec_helper'

describe DedupeReferenceSections do
  #ZZZ
  describe ".dedupe" do
  it "destroys duplicate reference section" do
    taxon = create_genus
    taxon.reference_sections.create references_taxt: 'Taxt', position: 2
    taxon.reference_sections.create references_taxt: 'Taxt', position: 1
    taxon.reference_sections.create references_taxt: 'Not taxt', position: 3
    taxon.reload

    expect(taxon.reference_sections.count).to eq 3

    DedupeReferenceSections.dedupe

    taxon.reload
    expect(taxon.reference_sections.count).to eq 2
    expect(taxon.reference_sections.map do |reference_section|
      [reference_section.position, reference_section.references_taxt]
    end).to match_array [[1, 'Taxt'], [3, 'Not taxt']]
  end
  end
end
