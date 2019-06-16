require 'spec_helper'

describe Names::BuildNameFromString do
  describe '#call' do
    context 'when name is a family name' do
      specify do
        name = described_class['Formicidae']

        expect(name).to be_a FamilyName
        expect(name.name).to eq 'Formicidae'

        expect { name.valid? }.to change { name.epithet }.to eq 'Formicidae'
      end
    end

    context 'when name is a subfamily name' do
      specify do
        name = described_class['Myrmecinae']

        expect(name).to be_a SubfamilyName
        expect(name.name).to eq 'Myrmecinae'

        expect { name.valid? }.to change { name.epithet }.to 'Myrmecinae'
      end
    end

    context 'when name is a tribe name' do
      specify do
        name = described_class['Attini']

        expect(name).to be_a TribeName
        expect(name.name).to eq 'Attini'

        expect { name.valid? }.to change { name.epithet }.to 'Attini'
      end
    end

    context 'when name is a genus name' do
      specify do
        name = described_class['Lasius']

        expect(name).to be_a GenusName
        expect(name.name).to eq 'Lasius'

        expect { name.valid? }.to change { name.epithet }.to 'Lasius'
      end
    end

    context 'when name is a subgenus name' do
      specify do
        name = described_class['Camponotus (Forelophilus)']

        expect(name).to be_a SubgenusName
        expect(name.name).to eq 'Camponotus (Forelophilus)'

        expect { name.valid? }.to change { name.epithet }.to 'Forelophilus'
      end
    end

    context 'when name is a species name' do
      specify do
        name = described_class['Lasius niger']

        expect(name).to be_a SpeciesName
        expect(name.name).to eq 'Lasius niger'

        expect { name.valid? }.to change { name.epithet }.to 'niger'
      end

      context 'when name includes subgenus' do
        specify do
          name = described_class['Formica (Hypochira) subspinosa']

          expect(name).to be_a SpeciesName
          expect(name.name).to eq 'Formica (Hypochira) subspinosa'

          expect { name.valid? }.to change { name.epithet }.to 'subspinosa'
        end
      end
    end

    # TODO: This should also cover subspecies names with 4 name parts:
    # * "Lasius (Forelophilus) niger fusca"
    # * "Lasius (Forelophilus) niger var. fusca"
    # * "Lasius niger var. fusca"
    # It works for now since we treat infrasubspecific names as `SubspeciesName`s.
    context 'when name is a subspecies name' do
      specify do
        name = described_class['Lasius niger fusca']

        expect(name).to be_a SubspeciesName
        expect(name.name).to eq 'Lasius niger fusca'
        expect(name.epithets).to eq nil

        expect { name.valid? }.to change { name.epithet }.to 'fusca'
        expect(name.epithets).to eq 'niger fusca'
      end
    end

    # TODO: We're parsing these as `SubspeciesName` because we don't fully support
    # infrasubspecific name yet, and there are already ~2k of them in the database.
    context 'when name is an infrasubspecies name' do
      context 'when 4 name parts' do
        specify do
          name = described_class['Leptothorax rottenbergi scabrosus kabyla']

          expect(name).to be_a SubspeciesName
          expect(name.name).to eq 'Leptothorax rottenbergi scabrosus kabyla'
          expect(name.epithets).to eq nil

          expect { name.valid? }.to change { name.epithet }.to 'kabyla'
          expect(name.epithets).to eq 'rottenbergi scabrosus kabyla'
        end
      end

      context 'when 5 name parts' do
        specify do
          name = described_class['Leptothorax (Hypochira) rottenbergi scabrosus kabyla']

          expect(name).to be_a SubspeciesName
          expect(name.name).to eq 'Leptothorax (Hypochira) rottenbergi scabrosus kabyla'
          expect(name.epithets).to eq nil

          expect { name.valid? }.to change { name.epithet }.to 'kabyla'
          expect(name.epithets).to eq '(Hypochira) rottenbergi scabrosus kabyla'
        end
      end

      context 'when 6 name parts' do
        specify do
          name = described_class['Camponotus herculeanus subsp. pennsylvanicus var. mahican']

          expect(name).to be_a SubspeciesName
          expect(name.name).to eq 'Camponotus herculeanus subsp. pennsylvanicus var. mahican'
          expect(name.epithets).to eq nil

          expect { name.valid? }.to change { name.epithet }.to 'mahican'
          expect(name.epithets).to eq 'herculeanus subsp. pennsylvanicus var. mahican'
        end
      end
    end

    context 'when input cannot be parsed into a `Name`' do
      context 'when name starts with a lower-case letter' do
        specify { expect { described_class['lasius niger'] }.to raise_error described_class::UnparsableName }
      end

      context 'when name is blank' do
        specify { expect { described_class[nil] }.to raise_error described_class::UnparsableName }
        specify { expect { described_class[''] }.to raise_error described_class::UnparsableName }
      end

      # TODO: We want to support this for protonyms like
      # "Atta (Acromyrmex) moelleri subsp. panamensis var. angustata" which has this many parts since it concists of
      # [Genus] [(subgenus)] [species] [old-style notation] subspecies [old-style notation] [infrasubspecific]
      context 'when name has seven name parts' do
        specify { expect { described_class['One two three four five six seven'] }.to raise_error described_class::UnparsableName }
      end
    end
  end
end
