require 'rails_helper'

describe Names::IdentifyNameType do
  describe '#call' do
    context 'when name contains redundant spaces' do
      it 'squishes them' do
        expect(described_class[' Lasius niger  fusca ']).to eq SubspeciesName
      end
    end

    context 'when name is a family name' do
      specify { expect(described_class['Formicidae']).to eq FamilyName }
    end

    context 'when name is a subfamily name' do
      specify { expect(described_class['Myrmecinae']).to eq SubfamilyName }
    end

    context 'when name is a tribe name' do
      context "when name ends with 'ini'" do
        specify { expect(described_class['Attini']).to eq TribeName }
      end

      context "when name ends with 'ii'" do
        specify { expect(described_class['Cerapachysii']).to eq TribeName }
      end
    end

    context 'when name is a subtribe name' do
      context "when name ends with 'iti'" do
        specify { expect(described_class['Dacetiti']).to eq SubtribeName }
      end
    end

    context 'when name is a genus name' do
      specify { expect(described_class['Lasius']).to eq GenusName }
    end

    context 'when name is a subgenus name' do
      specify { expect(described_class['Camponotus (Forelophilus)']).to eq SubgenusName }
    end

    context 'when name is a species name' do
      specify { expect(described_class['Lasius niger']).to eq SpeciesName }

      context 'when name includes subgenus' do
        specify { expect(described_class['Formica (Hypochira) subspinosa']).to eq SpeciesName }
      end
    end

    context 'when name is a subspecies name' do
      specify { expect(described_class['Lasius niger fusca']).to eq SubspeciesName }

      context 'when name contains abbreivations' do
        specify { expect(described_class['Lasius niger var. fusca']).to eq SubspeciesName }
      end

      context 'when name includes subgenus' do
        specify { expect(described_class['Lasius (Forelophilus) niger fusca']).to eq SubspeciesName }
      end

      context 'when name contains abbreivations and includes subgenus' do
        specify { expect(described_class['Lasius (Forelophilus) niger var. fusca']).to eq SubspeciesName }
      end
    end

    context 'when name is an infrasubspecies name' do
      specify { expect(described_class['Leptothorax rottenbergi scabrosus kabyla']).to eq InfrasubspeciesName }

      context 'when 5 name parts' do
        specify { expect(described_class['Leptothorax (Hypochira) rottenbergi scabrosus kabyla']).to eq InfrasubspeciesName }
      end

      context 'when 6 name parts' do
        specify { expect(described_class['Camponotus herculeanus subsp. pennsylvanicus var. mahican']).to eq InfrasubspeciesName }
      end

      context 'when 7 name parts' do
        specify { expect(described_class['Atta (Acromyrmex) moelleri subsp. panamensis var. angustata']).to eq InfrasubspeciesName }
      end
    end

    context 'when input cannot be parsed into a `Name`' do
      context 'when name is blank' do
        specify { expect(described_class[nil]).to eq nil }
        specify { expect(described_class['']).to eq nil }
        specify { expect(described_class['  ']).to eq nil }
      end

      context 'when name contains unknown rank abbreivations' do
        specify { expect(described_class['Lasius niger very. fusca']).to eq nil }
      end

      context 'when name has too many countable name parts' do
        specify { expect(described_class['One two three four five']).to eq nil }
      end
    end
  end
end
