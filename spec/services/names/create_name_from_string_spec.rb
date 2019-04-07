require 'spec_helper'

describe Names::CreateNameFromString do
  describe '#call' do
    context 'when input is a subgenus name' do
      it 'creates a `SubgenusName`' do
        described_class['Camponotus (Forelophilus)']
        name = Name.last
        expect(name).to be_a SubgenusName
        expect(name.name).to eq 'Camponotus (Forelophilus)'
        expect(name.epithet).to eq 'Forelophilus'
      end
    end
  end
end
