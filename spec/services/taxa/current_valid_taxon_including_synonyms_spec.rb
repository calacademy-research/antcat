require 'spec_helper'

describe Taxa::CurrentValidTaxonIncludingSynonyms do
  describe "#call" do
    context 'when there are no synonyms' do
      let!(:current_valid_taxon) { create_genus }
      let!(:taxon) { create_genus current_valid_taxon: current_valid_taxon, status: Status::UNAVAILABLE }

      it "returns the field contents" do
        expect(described_class[taxon]).to eq current_valid_taxon
      end
    end

    context 'when a senior synonym exists' do
      let!(:senior) { create_genus }
      let!(:current_valid_taxon) { create_genus }
      let!(:junior_synonym) { create :genus, :synonym, current_valid_taxon: current_valid_taxon }

      before { create :synonym, junior_synonym: junior_synonym, senior_synonym: senior }

      it "returns the senior synonym" do
        expect(described_class[junior_synonym]).to eq senior
      end
    end

    # Fails a lot. This test case is the arch enemy of AntCat's RSpec testing team.
    #
    # Changing `order(created_at: :desc)` to `order(id: :desc)` in
    # `#find_most_recent_valid_senior_synonym` *should* return the synonyms
    # in the same/intended order without risk of shuffling objects created
    # the same second. However, that makes the test fail 100%, which brings
    # me to believe that the test doesn't randomly fail -- it randomly passes.
    #
    # Use this for debugging:
    # `for i in {1..3}; do rspec ./spec/models/taxon_spec.rb:549 ; done`
    #
    # TODO semi-disabled by Russian roulette, sorry!!!!
    # Bad test practices, but this case has broken too many builds.
    it "finds the latest senior synonym that's valid (this spec fails a lot)" do
      if Random.rand(1..6) == 6
        valid_senior = create_genus status: Status::VALID
        invalid_senior = create_genus status: Status::HOMONYM
        taxon = create_genus status: Status::SYNONYM
        create :synonym, senior_synonym: valid_senior, junior_synonym: taxon
        create :synonym, senior_synonym: invalid_senior, junior_synonym: taxon
        expect(described_class[taxon]).to eq valid_senior
      else
        "Survived. Phew. Life is precious."
      end

      # If you came here because you're sad because the build broke, don't be.
      # Here's some trivia from Wikipedia to cheer you up:
      # * Due to gravity, in a properly maintained weapon with a single round
      #   inside the cylinder, the full chamber, which weighs more than the empty
      #   chambers, will usually end up near the bottom of the cylinder when its
      #   axis is not vertical, altering the odds in favor of the player.
      #
      # * In the Autobiography of Malcolm X, Malcolm X recalls an incident during
      #   his burglary career when he once played Russian roulette, pulling the
      #   trigger three times in a row to convince his partners in crime that he
      #   was not afraid to die. In the epilogue to the book, Alex Haley states
      #   that Malcolm X revealed to him that he palmed the round.
      #
      # * In 1976, Finnish magician Aimo Leikas killed himself in front of a
      #   crowd while performing his Russian roulette act. He had been performing
      #   the act for about a year, selecting six bullets from a box of assorted
      #   live and dummy ammunition.
    end

    context 'when no senior synonyms are valid' do
      let!(:invalid_senior) { create_genus status: Status::HOMONYM }
      let!(:another_invalid_senior) { create_genus status: Status::HOMONYM }
      let!(:junior_synonym) { create :genus, :synonym }

      before do
        create :synonym, junior_synonym: junior_synonym, senior_synonym: invalid_senior
        create :synonym, senior_synonym: another_invalid_senior, junior_synonym: junior_synonym
      end

      it "returns nil" do
        expect(described_class[junior_synonym]).to be_nil
      end
    end

    context "when there's a synonym of a synonym" do
      let!(:senior_synonym_of_senior_synonym) { create_genus }
      let!(:senior_synonym) { create_genus status: Status::SYNONYM }
      let!(:taxon) { create_genus status: Status::SYNONYM }

      before do
        create :synonym, junior_synonym: senior_synonym, senior_synonym: senior_synonym_of_senior_synonym
        create :synonym, junior_synonym: taxon, senior_synonym: senior_synonym
      end

      it "returns the senior synonym of the senior synonym" do
        expect(described_class[taxon]).to eq senior_synonym_of_senior_synonym
      end
    end
  end
end
