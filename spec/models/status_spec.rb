# frozen_string_literal: true

require 'rails_helper'

describe Status do
  describe '.cannot_have_current_taxon? and .requires_current_taxon?' do
    specify do
      [
        Status::SYNONYM,
        Status::OBSOLETE_COMBINATION,
        Status::UNAVAILABLE_MISSPELLING
      ].each do |status|
        expect(described_class.cannot_have_current_taxon?(status)).to eq false
        expect(described_class.requires_current_taxon?(status)).to eq true
      end

      [
        Status::VALID,
        Status::UNIDENTIFIABLE,
        Status::UNAVAILABLE,
        Status::EXCLUDED_FROM_FORMICIDAE,
        Status::HOMONYM
      ].each do |status|
        expect(described_class.cannot_have_current_taxon?(status)).to eq true
        expect(described_class.requires_current_taxon?(status)).to eq false
      end
    end
  end
end
