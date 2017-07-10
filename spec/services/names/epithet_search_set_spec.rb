require 'spec_helper'

describe Names::EpithetSearchSet do
  describe "masculine-feminine-neuter" do
    describe "first declension" do
      it "converts between these" do
        expect(epithet_search 'subterranea').to eq ['subterranea', 'subterraneus', 'subterraneum']
        expect(epithet_search 'subterraneus').to eq ['subterraneus', 'subterranea', 'subterraneum']
        expect(epithet_search 'subterraneum').to eq ['subterraneum', 'subterraneus', 'subterranea']
        expect(epithet_search 'equus').to eq ['equus', 'equa', 'equum']
        expect(epithet_search 'anea').to eq ['anea', 'aneus', 'aneum']
        expect(epithet_search 'fuscobarius').to eq ['fuscobarius', 'fuscobaria', 'fuscobarium']
        expect(epithet_search 'euguniae').to eq ['euguniae', 'eugunii']
        expect(epithet_search 'eugunii').to eq ['eugunii', 'euguniae', 'euguni']
      end
    end

    describe "first and second declension adjectives in -er" do
      it "handles (at least) coniger" do
        expect(epithet_search 'coniger')
          .to eq ['coniger', 'conigera', 'conigerum', 'conigaer']
        expect(epithet_search 'conigera')
          .to eq ['conigera', 'conigerus', 'conigerum', 'coniger', 'conigaera']
        expect(epithet_search 'conigerum')
          .to eq ['conigerum', 'conigerus', 'conigera', 'coniger', 'conigaerum']
      end
    end

    describe "third declension" do
      it "converts between these" do
        expect(epithet_search 'fatruele').to eq ['fatruele', 'fatruelis']
        expect(epithet_search 'fatruelis').to eq ['fatruelis', 'fatruele']
      end
    end
  end

  describe "names deemed identical" do
    it "handles -i and -ii" do
      expect(epithet_search 'lundii').to eq ['lundii', 'lundiae', 'lundi']
      expect(epithet_search 'lundi').to eq ['lundi', 'lundae', 'lundii']
      expect(epithet_search 'lundae').to eq ['lundae', 'lundi']
    end

    it "handles -e- and -ae-" do
      expect(epithet_search 'letis').to eq ['letis', 'lete', 'laetis']
      expect(epithet_search 'laetis').to eq ['laetis', 'laete', 'letis']
    end

    it "handles -p- and -ph-" do
      expect(epithet_search 'delpina').to eq ['delpina', 'delpinus', 'delpinum', 'delphina']
    end

    it "handles -v- and -w-" do
      expect(epithet_search 'acwabimans').to eq ['acwabimans', 'acvabimans']
      expect(epithet_search 'acvabimans').to eq ['acvabimans', 'acwabimans']
    end
  end

  describe "frequently misspelled names" do
    it "translates them, but just one time and in only one direction" do
      expect(epithet_search 'alfaroi').to eq ['alfaroi', 'alfari']
      expect(epithet_search 'alfari').to eq ['alfari', 'alfarae', 'alfarii']
      expect(epithet_search 'columbica').to eq ['columbica', 'colombica', 'columbicus', 'columbicum']
    end
  end
end

def epithet_search string
  described_class.new(string).epithets
end
