# frozen_string_literal: true

require 'rails_helper'

describe Names::EpithetSearchSet do
  describe "#call" do
    describe "masculine-feminine-neuter" do
      describe "first declension" do
        it "converts between these" do
          expect(described_class['subterranea']).to eq ['subterranea', 'subterraneus', 'subterraneum']
          expect(described_class['subterraneus']).to eq ['subterraneus', 'subterranea', 'subterraneum']
          expect(described_class['subterraneum']).to eq ['subterraneum', 'subterraneus', 'subterranea']
          expect(described_class['equus']).to eq ['equus', 'equa', 'equum']
          expect(described_class['anea']).to eq ['anea', 'aneus', 'aneum']
          expect(described_class['fuscobarius']).to eq ['fuscobarius', 'fuscobaria', 'fuscobarium']
          expect(described_class['euguniae']).to eq ['euguniae', 'eugunii']
          expect(described_class['eugunii']).to eq ['eugunii', 'euguniae', 'euguni']
        end
      end

      describe "first and second declension adjectives in -er" do
        it "handles (at least) coniger" do
          expect(described_class['coniger']).
            to eq ['coniger', 'conigera', 'conigerum', 'conigaer']
          expect(described_class['conigera']).
            to eq ['conigera', 'conigerus', 'conigerum', 'coniger', 'conigaera']
          expect(described_class['conigerum']).
            to eq ['conigerum', 'conigerus', 'conigera', 'coniger', 'conigaerum']
        end
      end

      describe "third declension" do
        it "converts between these" do
          expect(described_class['fatruele']).to eq ['fatruele', 'fatruelis']
          expect(described_class['fatruelis']).to eq ['fatruelis', 'fatruele']
        end
      end
    end

    describe "names deemed identical" do
      it "handles -i and -ii" do
        expect(described_class['lundii']).to eq ['lundii', 'lundiae', 'lundi']
        expect(described_class['lundi']).to eq ['lundi', 'lundae', 'lundii']
        expect(described_class['lundae']).to eq ['lundae', 'lundi']
      end

      it "handles -e- and -ae-" do
        expect(described_class['letis']).to eq ['letis', 'lete', 'laetis']
        expect(described_class['laetis']).to eq ['laetis', 'laete', 'letis']
      end

      it "handles -p- and -ph-" do
        expect(described_class['delpina']).to eq ['delpina', 'delpinus', 'delpinum', 'delphina']
      end

      it "handles -v- and -w-" do
        expect(described_class['acwabimans']).to eq ['acwabimans', 'acvabimans']
        expect(described_class['acvabimans']).to eq ['acvabimans', 'acwabimans']
      end
    end

    describe "frequently misspelled names" do
      it "translates them, but just one time and in only one direction" do
        expect(described_class['alfaroi']).to eq ['alfaroi', 'alfari']
        expect(described_class['alfari']).to eq ['alfari', 'alfarae', 'alfarii']
        expect(described_class['columbica']).to eq ['columbica', 'colombica', 'columbicus', 'columbicum']
      end
    end
  end
end
