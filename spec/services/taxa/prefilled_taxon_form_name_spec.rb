# frozen_string_literal: true

require 'rails_helper'

describe Taxa::PrefilledTaxonFormName do
  describe "#call" do
    context "when initial parts of taxon's name cannot be inferred from parent's name" do
      let(:taxon) { create :tribe }

      specify { expect(described_class[taxon]).to eq nil }
    end

    context 'when taxon is a subgenus' do
      let(:taxon) { create :subgenus }

      it "uses its genus' name" do
        expect(described_class[taxon]).to eq "#{taxon.genus.name_cache} "
      end
    end

    context 'when taxon is a species' do
      let(:taxon) { create :species }

      it "uses its genus' name" do
        expect(described_class[taxon]).to eq "#{taxon.genus.name_cache} "
      end
    end

    context 'when taxon is a subspecies' do
      let(:taxon) { create :subspecies }

      it "uses its species' name" do
        expect(described_class[taxon]).to eq "#{taxon.species.name_cache} "
      end
    end

    context 'when taxon is an infrasubspecies' do
      let(:taxon) { create :infrasubspecies }

      it "uses its subspecies' name" do
        expect(described_class[taxon]).to eq "#{taxon.subspecies.name_cache} "
      end
    end
  end
end
