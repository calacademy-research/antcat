# frozen_string_literal: true

require 'rails_helper'

describe Types::LinkSpecimenIdentifiers do
  describe '#call' do
    it 'links' do
      expanded_identifier = "<a href='https://www.antweb.org/specimen/CASENT123'>CASENT123</a>"

      expect(described_class['CASENT123']).to eq expanded_identifier
      expect(described_class['one CASENT123 three']).to eq "one #{expanded_identifier} three"
      expect(described_class['one (CASENT123)']).to eq "one (#{expanded_identifier})"
    end

    it 'respects word boundaries' do
      expect(described_class['hiCASENT123']).to eq "hiCASENT123"
    end
  end
end
