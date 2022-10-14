# frozen_string_literal: true

require 'rails_helper'

module Test
  class ReferenceDateFormatValidatable
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :date

    validates :date, reference_date_format: true
  end
end

describe ReferenceDateFormatValidator do
  let(:validatable_class) { Test::ReferenceDateFormatValidatable }

  describe 'invalid cases' do
    describe 'error message' do
      let(:validatable) { validatable_class.new(date: '20-22') }

      specify do
        expect(validatable.valid?).to eq false
        expect(validatable.errors[:date]).to eq([described_class::ERROR_MESSAGE])
      end
    end

    [
      '2022<',         # Invalid character.
      '2022a',         # Invalid character.
      '22-01-91',      # Year cannot be shortened.
      '20-22',         # Misplaced dash.
      '2022-1-1',      # Missing leading zeros for month/day.
      '2022-01-01-01', # Too long.
      '2022-0101',     # Unbalanced dashes.
      '2022-01?-01'    # Question marks are only allowed as the last character.
    ].each do |date|
      it "considers '#{date}' as an invalid date" do
        validatable = validatable_class.new(date: date)
        expect(validatable.valid?).to eq false
      end
    end
  end

  describe 'valid cases' do
    [
      # Separated by dashes.
      '2022',
      '2022-01',
      '2022-01-01',

      # Without dashes.
      '202201',
      '20220101',

      # With trailing question mark.
      '2022?',
      '2022-01?',
      '2022-01-01?'
    ].each do |date|
      it "considers '#{date}' as a valid date" do
        validatable = validatable_class.new(date: date)
        expect(validatable.valid?).to eq true
      end
    end
  end
end
