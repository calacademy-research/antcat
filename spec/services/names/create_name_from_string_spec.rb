require 'spec_helper'

describe Names::CreateNameFromString do
  describe '#call' do
    context 'when input is a subgenus name' do
      it 'creates a `SubgenusName`' do
        described_class['Camponotus (Forelophilus)']
        name = Name.last
        expect(name).to be_a SubgenusName
        expect(name.name).to eq 'Camponotus (Forelophilus)'
        expect(name.name_html).to eq '<i>Camponotus (Forelophilus)</i>'
        expect(name.name_to_html).to eq '<i>Camponotus (Forelophilus)</i>'
        expect(name.epithet).to eq 'Forelophilus'
        expect(name.epithet_html).to eq '<i>Forelophilus</i>'
      end
    end
  end
end
