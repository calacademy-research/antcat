require 'spec_helper'

describe EpithetSearchSet do
  describe "masculine-feminine-neuter" do
    describe "first declension" do
      it "converts between these" do
        expect(EpithetSearchSet.new('subterranea').epithets).to eq ['subterranea', 'subterraneus', 'subterraneum']
        expect(EpithetSearchSet.new('subterraneus').epithets).to eq ['subterraneus', 'subterranea', 'subterraneum']
        expect(EpithetSearchSet.new('subterraneum').epithets).to eq ['subterraneum', 'subterraneus', 'subterranea']
        expect(EpithetSearchSet.new('equus').epithets).to eq ['equus', 'equa', 'equum']
        expect(EpithetSearchSet.new('anea').epithets).to eq ['anea', 'aneus', 'aneum']
        expect(EpithetSearchSet.new('fuscobarius').epithets).to eq ['fuscobarius', 'fuscobaria', 'fuscobarium']
        expect(EpithetSearchSet.new('euguniae').epithets).to eq ['euguniae', 'eugunii']
        expect(EpithetSearchSet.new('eugunii').epithets).to eq ['eugunii', 'euguniae', 'euguni']
      end
    end

    describe "first and second declension adjectives in -er" do
      it "handles (at least) coniger" do
        expect(EpithetSearchSet.new('coniger').epithets)
          .to eq ['coniger', 'conigera', 'conigerum', 'conigaer']
        expect(EpithetSearchSet.new('conigera').epithets)
          .to eq ['conigera', 'conigerus', 'conigerum', 'coniger', 'conigaera']
        expect(EpithetSearchSet.new('conigerum').epithets)
          .to eq ['conigerum', 'conigerus', 'conigera', 'coniger', 'conigaerum']
      end
    end

    describe "third declension" do
      it "converts between these" do
        expect(EpithetSearchSet.new('fatruele').epithets).to eq ['fatruele', 'fatruelis']
        expect(EpithetSearchSet.new('fatruelis').epithets).to eq ['fatruelis', 'fatruele']
      end
    end
  end

  describe "names deemed identical" do
    it "handles -i and -ii" do
      expect(EpithetSearchSet.new('lundii').epithets).to eq ['lundii', 'lundiae', 'lundi']
      expect(EpithetSearchSet.new('lundi').epithets).to eq ['lundi', 'lundae', 'lundii']
      expect(EpithetSearchSet.new('lundae').epithets).to eq ['lundae', 'lundi']
    end

    it "handles -e- and -ae-" do
      expect(EpithetSearchSet.new('letis').epithets).to eq ['letis', 'lete', 'laetis']
      expect(EpithetSearchSet.new('laetis').epithets).to eq ['laetis', 'laete', 'letis']
    end

    it "handles -p- and -ph-" do
      expect(EpithetSearchSet.new('delpina').epithets).to eq ['delpina', 'delpinus', 'delpinum', 'delphina']
    end

    it "handles -v- and -w-" do
      expect(EpithetSearchSet.new('acwabimans').epithets).to eq ['acwabimans', 'acvabimans']
      expect(EpithetSearchSet.new('acvabimans').epithets).to eq ['acvabimans', 'acwabimans']
    end
  end

  describe "frequently misspelled names" do
    it "translates them, but just one time and in only one direction" do
      expect(EpithetSearchSet.new('alfaroi').epithets).to eq ['alfaroi', 'alfari']
      expect(EpithetSearchSet.new('alfari').epithets).to eq ['alfari', 'alfarae', 'alfarii']
      expect(EpithetSearchSet.new('columbica').epithets).to eq ['columbica', 'colombica', 'columbicus', 'columbicum']
    end
  end
end
