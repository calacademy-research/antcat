require 'spec_helper'

describe CleanNewlines do
  it "removes newlines and linefeeds before saving" do
    taxon = taxon_with_headline "Te\nxt"
    expect(taxon.headline_notes_taxt).to eq 'Text'
  end

  it "handles all fields" do
    taxon = taxon_with_headline "Te\nxt", type_taxt: "\nType"
    expect(taxon.headline_notes_taxt).to eq 'Text'
    expect(taxon.type_taxt).to eq 'Type'
  end

  it "removes newlines and carriage returns" do
    taxon = taxon_with_headline "\rTe\nxt"
    expect(taxon.headline_notes_taxt).to eq 'Text'
  end

  it "handles nil" do
    taxon = taxon_with_headline nil
    expect(taxon.headline_notes_taxt).to be_nil
  end

  it "handles empty strings" do
    taxon = taxon_with_headline ''
    expect(taxon.headline_notes_taxt).to be_empty
  end
end

def taxon_with_headline headline_notes_taxt, type_taxt: nil
  if type_taxt
    create :genus, headline_notes_taxt: headline_notes_taxt, type_taxt: type_taxt
  else
    create :genus, headline_notes_taxt: headline_notes_taxt
  end
end
