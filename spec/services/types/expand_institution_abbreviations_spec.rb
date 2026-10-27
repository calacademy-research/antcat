# frozen_string_literal: true

require 'rails_helper'

describe Types::ExpandInstitutionAbbreviations do
  describe '#call' do
    context 'when there are no institutions in the database' do
      it 'returns the content as is' do
        expect(described_class['CASC']).to eq "CASC"
      end
    end

    context 'when an institution has a blank abbreviation (legacy data)' do
      before do
        create :institution, :casc
        create(:institution).update_columns(abbreviation: '')
      end

      it 'ignores it' do
        expect(described_class['CASC x']).to eq "<abbr title='California Academy of Sciences'>CASC</abbr> x"
      end
    end

    context 'when there are institutions in the database' do
      before do
        create :institution, :casc
      end

      it 'expands institution abbreviations' do
        casc_expanded = "<abbr title='California Academy of Sciences'>CASC</abbr>"

        expect(described_class['CASC']).to eq casc_expanded
        expect(described_class['CASC CASC']).to eq "#{casc_expanded} #{casc_expanded}"
        expect(described_class['one (CASC) three']).to eq "one (#{casc_expanded}) three"
        expect(described_class['CASC)']).to eq "#{casc_expanded})"
        expect(described_class['CASC]']).to eq "#{casc_expanded}]"
        expect(described_class['CASC/']).to eq "#{casc_expanded}/"
        expect(described_class['CASC.']).to eq "#{casc_expanded}."
        expect(described_class['CASC,']).to eq "#{casc_expanded},"
        expect(described_class['CASC;']).to eq "#{casc_expanded};"
      end

      it 'respects word boundaries' do
        expect(described_class['CASCADE']).to eq "CASCADE"
        expect(described_class['hiCASC']).to eq "hiCASC"
        expect(described_class['CASC-1']).to eq "CASC-1"
      end

      context 'when abbreviations contain regex special characters (e.g. records saved before validation)' do
        before do
          ['\w+', '|', '(', 'A.C'].each do |abbreviation|
            build(:institution, abbreviation: abbreviation).save!(validate: false)
          end
        end

        it 'matches abbreviations literally' do
          expect(described_class['CASC text (ABC)']).to eq(
            "<abbr title='California Academy of Sciences'>CASC</abbr> text (ABC)"
          )
          expect(described_class['ABC']).to eq "ABC"
        end
      end

      context 'when institution name contains apostrophes' do
        before { create :institution, abbreviation: 'MH', name: "Musee d'Histoire" }

        it 'escapes the expansion with HTML entities' do
          expect(described_class['MH']).to eq "<abbr title='Musee d&#39;Histoire'>MH</abbr>"
        end
      end
    end
  end
end
