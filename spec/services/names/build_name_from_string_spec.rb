require 'rails_helper'

describe Names::BuildNameFromString do
  describe '#call' do
    context 'when name contains redundant spaces' do
      it 'squishes them' do
        name = described_class[' Lasius niger  fusca ']

        expect(name).to be_a SubspeciesName
        expect(name.name).to eq 'Lasius niger fusca'
        expect(name.epithet).to eq 'fusca'
      end
    end

    context 'when name is a family name' do
      specify do
        name = described_class['Formicidae']

        expect(name).to be_a FamilyName
        expect(name.name).to eq 'Formicidae'
        expect(name.epithet).to eq 'Formicidae'
      end
    end

    context 'when name is a subfamily name' do
      specify do
        name = described_class['Myrmecinae']

        expect(name).to be_a SubfamilyName
        expect(name.name).to eq 'Myrmecinae'
        expect(name.epithet).to eq 'Myrmecinae'
      end
    end

    context 'when name is a tribe name' do
      specify do
        name = described_class['Attini']

        expect(name).to be_a TribeName
        expect(name.name).to eq 'Attini'
        expect(name.epithet).to eq 'Attini'
      end
    end

    context 'when name is a genus name' do
      specify do
        name = described_class['Lasius']

        expect(name).to be_a GenusName
        expect(name.name).to eq 'Lasius'
        expect(name.epithet).to eq 'Lasius'
      end
    end

    context 'when name is a subgenus name' do
      specify do
        name = described_class['Camponotus (Forelophilus)']

        expect(name).to be_a SubgenusName
        expect(name.name).to eq 'Camponotus (Forelophilus)'
        expect(name.epithet).to eq 'Forelophilus'
      end
    end

    context 'when name is a species name' do
      specify do
        name = described_class['Lasius niger']

        expect(name).to be_a SpeciesName
        expect(name.name).to eq 'Lasius niger'
        expect(name.epithet).to eq 'niger'
      end

      context 'when name includes subgenus' do
        specify do
          name = described_class['Formica (Hypochira) subspinosa']

          expect(name).to be_a SpeciesName
          expect(name.name).to eq 'Formica (Hypochira) subspinosa'
          expect(name.epithet).to eq 'subspinosa'
        end
      end
    end

    context 'when name is a subspecies name' do
      specify do
        name = described_class['Lasius niger fusca']

        expect(name).to be_a SubspeciesName
        expect(name.name).to eq 'Lasius niger fusca'
        expect(name.epithet).to eq 'fusca'
      end

      context 'when name contains abbreivations' do
        specify do
          name = described_class['Lasius niger var. fusca']

          expect(name).to be_a SubspeciesName
          expect(name.name).to eq 'Lasius niger var. fusca'
          expect(name.epithet).to eq 'fusca'
        end
      end

      context 'when name includes subgenus' do
        specify do
          name = described_class['Lasius (Forelophilus) niger fusca']

          expect(name).to be_a SubspeciesName
          expect(name.name).to eq 'Lasius (Forelophilus) niger fusca'
          expect(name.epithet).to eq 'fusca'
        end
      end

      context 'when name contains abbreivations and includes subgenus' do
        specify do
          name = described_class['Lasius (Forelophilus) niger var. fusca']

          expect(name).to be_a SubspeciesName
          expect(name.name).to eq 'Lasius (Forelophilus) niger var. fusca'
          expect(name.epithet).to eq 'fusca'
        end
      end
    end

    context 'when name is an infrasubspecies name' do
      context 'when 4 name parts' do
        specify do
          name = described_class['Leptothorax rottenbergi scabrosus kabyla']

          expect(name).to be_a InfrasubspeciesName
          expect(name.name).to eq 'Leptothorax rottenbergi scabrosus kabyla'
          expect(name.epithet).to eq 'kabyla'
        end
      end

      context 'when 5 name parts' do
        specify do
          name = described_class['Leptothorax (Hypochira) rottenbergi scabrosus kabyla']

          expect(name).to be_a InfrasubspeciesName
          expect(name.name).to eq 'Leptothorax (Hypochira) rottenbergi scabrosus kabyla'
          expect(name.epithet).to eq 'kabyla'
        end
      end

      context 'when 6 name parts' do
        specify do
          name = described_class['Camponotus herculeanus subsp. pennsylvanicus var. mahican']

          expect(name).to be_a InfrasubspeciesName
          expect(name.name).to eq 'Camponotus herculeanus subsp. pennsylvanicus var. mahican'
          expect(name.epithet).to eq 'mahican'
        end
      end

      context 'when 7 name parts' do
        specify do
          name = described_class['Atta (Acromyrmex) moelleri subsp. panamensis var. angustata']

          expect(name).to be_a InfrasubspeciesName
          expect(name.name).to eq 'Atta (Acromyrmex) moelleri subsp. panamensis var. angustata'
          expect(name.epithet).to eq 'angustata'
        end
      end
    end

    context 'when input cannot be parsed into a `Name`' do
      context 'when name is blank' do
        specify do
          name = described_class[nil]

          expect(name).to be_a Name
          expect(name.name).to eq nil
          expect(name.epithet).to eq nil
        end

        specify do
          name = described_class['']

          expect(name).to be_a Name
          expect(name.name).to eq nil
          expect(name.epithet).to eq nil
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
