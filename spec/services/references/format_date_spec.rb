# frozen_string_literal: true

require 'rails_helper'

describe References::FormatDate do
  describe '#call' do
    context 'when date includes year, month and day' do
      it "returns the date in ISO 8601 format" do
        expect(described_class['20101213']).to eq '2010-12-13'
      end
    end

    context 'when date includes only year and month' do
      specify { expect(described_class['201012']).to eq '2010-12' }
    end

    context 'when date includes only year' do
      specify { expect(described_class['2010']).to eq '2010' }
    end

    context 'when date is blank' do
      specify { expect(described_class['']).to eq '' }
      specify { expect(described_class[nil]).to eq nil }
    end
  end
end
