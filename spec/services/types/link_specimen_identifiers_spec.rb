require 'rails_helper'

describe Types::LinkSpecimenIdentifiers do
  describe '#call' do
    let!(:casent_expanded) do
      "<a href='https://www.antweb.org/specimen/CASENT123'>CASENT123</a>"
    end

    it 'links' do
      expect(described_class['CASENT123']).to eq casent_expanded
      expect(described_class['one CASENT123 three']).to eq "one #{casent_expanded} three"
      expect(described_class['one (CASENT123)']).to eq "one (#{casent_expanded})"
    end

    it 'respects word boundaries' do
      expect(described_class['hiCASENT123']).to eq "hiCASENT123"
    end
  end
end
