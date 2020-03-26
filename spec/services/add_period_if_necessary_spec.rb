# frozen_string_literal: true

require 'rails_helper'

describe AddPeriodIfNecessary do
  describe "#call" do
    specify { expect(described_class['Hi']).to eq 'Hi.' }
    specify { expect(described_class['Hi.']).to eq 'Hi.' }
    specify { expect(described_class['Hi!']).to eq 'Hi!' }
    specify { expect(described_class['Hi?']).to eq 'Hi?' }
    specify { expect(described_class['']).to eq '' }
    specify { expect(described_class[nil]).to eq '' }
  end
end
