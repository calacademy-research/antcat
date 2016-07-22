require 'spec_helper'

describe CleanNewlines do

  it "should remove newlines and linefeeds before saving" do
    taxon = create :genus, headline_notes_taxt: "Te\nxt"
    taxon.save!
    expect(taxon.headline_notes_taxt).to eq 'Text'
  end

  it "should handle all fields" do
    taxon = create :genus, headline_notes_taxt: "Te\nxt", type_taxt: "\nType"
    taxon.save!
    expect(taxon.headline_notes_taxt).to eq 'Text'
    expect(taxon.type_taxt).to eq 'Type'
  end

  it "should handle newlines and carriage returns" do
    taxon = create :genus, headline_notes_taxt: "\rTe\nxt"
    taxon.save!
    expect(taxon.headline_notes_taxt).to eq 'Text'
  end

  it "should handle nil" do
    taxon = create :genus, headline_notes_taxt: nil
    taxon.save!
    expect(taxon.headline_notes_taxt).to be_nil
  end

  it "should handle an empty string" do
    taxon = create :genus, headline_notes_taxt: ''
    taxon.save!
    expect(taxon.headline_notes_taxt).to be_empty
  end

end
