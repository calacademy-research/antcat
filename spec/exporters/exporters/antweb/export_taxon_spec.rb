# frozen_string_literal: true

require 'rails_helper'

describe Exporters::Antweb::ExportTaxon do
  include TestLinksHelpers

  describe "HEADER" do
    it "is the same as the code" do
      expected = "antcat id\t" \
        "subfamily\t" \
        "tribe\t" \
        "genus\t" \
        "subgenus\t" \
        "species\t" \
        "subspecies\t" \
        "author date\t" \
        "author date html\t" \
        "authors\t" \
        "year\t" \
        "status\t" \
        "available\t" \
        "current valid name\t" \
        "original combination\t" \
        "was original combination\t" \
        "fossil\t" \
        "taxonomic history html\t" \
        "reference id\t" \
        "bioregion\t" \
        "country\t" \
        "current valid rank\t" \
        "hol id\t" \
        "current valid parent"
      expect(described_class::HEADER).to eq expected
    end
  end

  describe "#call" do
    describe "exporting a subspecies`" do
      let(:taxon) { create :subspecies }

      specify do
        taxon_attributes = Exporters::Antweb::TaxonAttributes[taxon]
        results = described_class[taxon].split("\t")

        expect(results[0]).to eq taxon_attributes[:antcat_id].to_s
        expect(results[1]).to eq taxon_attributes[:subfamily].to_s
        expect(results[2]).to eq taxon_attributes[:tribe].to_s
        expect(results[3]).to eq taxon_attributes[:genus].to_s
        expect(results[4]).to eq taxon_attributes[:subgenus].to_s
        expect(results[5]).to eq taxon_attributes[:species].to_s
        expect(results[6]).to eq taxon_attributes[:subspecies].to_s
        expect(results[7]).to eq taxon_attributes[:author_date].to_s
        expect(results[8]).to eq taxon_attributes[:author_date_html].to_s
        expect(results[9]).to eq taxon_attributes[:authors].to_s
        expect(results[11]).to eq taxon_attributes[:status].to_s
        expect(results[12]).to eq({ true => 'TRUE', false => 'FALSE' }[taxon_attributes[:available]])
        expect(results[13]).to eq taxon_attributes[:current_valid_name].to_s
        expect(results[14]).to eq({ true => 'TRUE', false => 'FALSE' }[taxon_attributes[:original_combination]])
        expect(results[15]).to eq taxon_attributes[:was_original_combination].to_s
        expect(results[16]).to eq({ true => 'TRUE', false => 'FALSE' }[taxon_attributes[:fossil]])
        expect(results[17]).to eq taxon_attributes[:taxonomic_history_html].to_s
        expect(results[18]).to eq taxon_attributes[:reference_id].to_s
        expect(results[19]).to eq taxon_attributes[:bioregion].to_s
        expect(results[20]).to eq taxon_attributes[:country].to_s
        expect(results[21]).to eq taxon_attributes[:current_valid_rank].to_s
        expect(results[22]).to eq taxon_attributes[:hol_id].to_s
        expect(results[23]).to eq taxon_attributes[:current_valid_parent].to_s
      end
    end
  end
end
