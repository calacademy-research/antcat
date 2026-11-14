# frozen_string_literal: true

require 'rails_helper'

describe Protonyms::PredictGenderEpithets do
  describe "#call" do
    def forms epithet
      described_class[epithet]&.values
    end

    it "declines -us/-a/-um adjectives" do
      expect(forms('crassispina')).to eq %w[crassispinus crassispina crassispinum]
      expect(forms('rufus')).to eq %w[rufus rufa rufum]
      expect(forms('nitidum')).to eq %w[nitidus nitida nitidum]
    end

    it "declines third-declension adjectives (-is/-e)" do
      expect(forms('bicornis')).to eq %w[bicornis bicornis bicorne]
      expect(forms('howense')).to eq %w[howensis howensis howense]
    end

    it "declines -er adjectives, including compounds of niger" do
      expect(forms('niger')).to eq %w[niger nigra nigrum]
      expect(forms('alboniger')).to eq %w[alboniger albonigra albonigrum]
      expect(forms('ruber')).to eq %w[ruber rubra rubrum]
      expect(forms('lanigera')).to eq %w[laniger lanigera lanigerum]
    end

    it "keeps the e of -iger ('bearing') compounds that TaxonWorks takes for niger" do
      expect(forms('corniger')).to eq %w[corniger cornigera cornigerum]
      expect(forms('spiniger')).to eq %w[spiniger spinigera spinigerum]
      expect(forms('conigera')).to eq %w[coniger conigera conigerum]
    end

    it "declines comparatives" do
      expect(forms('major')).to eq %w[major major majus]
    end

    it "uses TaxonWorks' table of irregular adjectives first" do
      expect(forms('acris')).to eq %w[acer acris acre]
      expect(forms('libera')).to eq %w[liber libera liberum]
    end

    it "leaves one-form endings unchanged" do
      expect(forms('tricolor')).to eq %w[tricolor tricolor tricolor]
      expect(forms('longiceps')).to eq %w[longiceps longiceps longiceps]
    end

    it "cannot tell a noun from an adjective (the caller must check the part of speech)" do
      expect(forms('trochis')).to eq %w[trochis trochis troche]
    end

    it "returns nil for a blank epithet" do
      expect(described_class[nil]).to eq nil
      expect(described_class['']).to eq nil
    end

    it "returns the forms keyed by AntCat's genus genders" do
      expect(described_class['rufus'].keys).to eq Name::GENDERS
    end
  end
end
