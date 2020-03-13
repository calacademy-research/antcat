require 'rails_helper'

describe Names::BuildNameFromString do
  describe '#call' do
    context 'when name contains redundant spaces' do
      it 'squishes them' do
        name = described_class[' Lasius niger  fusca ']

        expect(name).to be_a SubspeciesName
        expect(name.name).to eq 'Lasius niger fusca'
      end
    end

    context 'when input cannot be parsed into a `Name`' do
      context 'when name is blank' do
        specify do
          name = described_class[nil]

          expect(name).to be_a Name
          expect(name.name).to eq nil
        end

        specify do
          name = described_class['']

          expect(name).to be_a Name
          expect(name.name).to eq nil
        end
      end

      context 'when name contains unknown rank abbreivations' do
        specify { expect { described_class['Lasius niger very. fusca'] }.to raise_error described_class::UnparsableName }
      end

      context 'when name has too many countable name parts' do
        specify { expect { described_class['One two three four five'] }.to raise_error described_class::UnparsableName }
      end
    end
  end
end
