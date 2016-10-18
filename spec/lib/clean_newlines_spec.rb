require 'spec_helper'

describe CleanNewlines do
  it "removes newlines and linefeeds before saving" do
    taxon = create :genus, headline_notes_taxt: "Te\nxt"
    taxon.save!
    expect(taxon.headline_notes_taxt).to eq 'Text'
  end

  it "handles all fields" do
    taxon = create :genus, headline_notes_taxt: "Te\nxt", type_taxt: "\nType"
    taxon.save!
    expect(taxon.headline_notes_taxt).to eq 'Text'
    expect(taxon.type_taxt).to eq 'Type'
  end

  it "handles newlines and carriage returns" do
    taxon = create :genus, headline_notes_taxt: "\rTe\nxt"
    taxon.save!
    expect(taxon.headline_notes_taxt).to eq 'Text'
  end

  it "handles nil" do
    taxon = create :genus, headline_notes_taxt: nil
    taxon.save!
    expect(taxon.headline_notes_taxt).to be_nil
  end

  it "handles empty strings" do
    taxon = create :genus, headline_notes_taxt: ''
    taxon.save!
    expect(taxon.headline_notes_taxt).to be_empty
  end
end
