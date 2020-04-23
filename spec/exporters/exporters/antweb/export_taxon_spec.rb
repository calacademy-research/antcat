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
        results = described_class[taxon]

        expect(results[0]).to eq taxon_attributes[:antcat_id]
        expect(results[1]).to eq taxon_attributes[:subfamily]
        expect(results[2]).to eq taxon_attributes[:tribe]
        expect(results[3]).to eq taxon_attributes[:genus]
        expect(results[4]).to eq taxon_attributes[:subgenus]
        expect(results[5]).to eq taxon_attributes[:species]
        expect(results[6]).to eq taxon_attributes[:subspecies]
        expect(results[7]).to eq taxon_attributes[:author_date]
        expect(results[8]).to eq taxon_attributes[:author_date_html]
        expect(results[9]).to eq taxon_attributes[:authors]
        expect(results[11]).to eq taxon_attributes[:status]
        expect(results[12]).to eq({ true => 'TRUE', false => 'FALSE' }[taxon_attributes[:available]])
        expect(results[13]).to eq taxon_attributes[:current_valid_name]
        expect(results[14]).to eq({ true => 'TRUE', false => 'FALSE' }[taxon_attributes[:original_combination]])
        expect(results[15]).to eq taxon_attributes[:was_original_combination]
        expect(results[16]).to eq({ true => 'TRUE', false => 'FALSE' }[taxon_attributes[:fossil]])
        expect(results[17]).to eq taxon_attributes[:taxonomic_history_html]
        expect(results[18]).to eq taxon_attributes[:reference_id]
        expect(results[19]).to eq taxon_attributes[:bioregion]
        expect(results[20]).to eq taxon_attributes[:country]
        expect(results[21]).to eq taxon_attributes[:current_valid_rank]
        expect(results[22]).to eq taxon_attributes[:hol_id]
        expect(results[23]).to eq taxon_attributes[:current_valid_parent]
      end
    end
  end
end
