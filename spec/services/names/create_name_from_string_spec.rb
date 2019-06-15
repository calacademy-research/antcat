require 'spec_helper'

describe Names::CreateNameFromString do
  describe '#call' do
    context 'when input is a subgenus name' do
      it 'creates a `SubgenusName`' do
        name = described_class['Camponotus (Forelophilus)']

        expect(name).to be_a SubgenusName
        expect(name.name).to eq 'Camponotus (Forelophilus)'
        expect(name.epithet).to eq 'Forelophilus'
      end
    end

    context 'when input cannot be parsed into a `Name`' do
      specify { expect { described_class[nil] }.to raise_error described_class::UnparsableName }
      specify { expect { described_class[''] }.to raise_error described_class::UnparsableName }
      specify { expect { described_class['one two three four five six'] }.to raise_error described_class::UnparsableName }
    end
  end
end
