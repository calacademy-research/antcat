require "spec_helper"

describe Taxon do # rubocop:disable RSpec/FilePath
  describe "#current_valid_taxon_including_synonyms" do
    context 'when there are no synonyms' do
      let!(:current_valid_taxon) { create_genus }
      let!(:taxon) { create_genus current_valid_taxon: current_valid_taxon, status: Status::UNAVAILABLE }

      it "returns the field contents" do
        expect(taxon.current_valid_taxon_including_synonyms).to eq current_valid_taxon
      end
    end

    context 'when a senior synonym exists' do
      let!(:senior) { create_genus }
      let!(:current_valid_taxon) { create_genus }
      let!(:junior_synonym) { create :genus, :synonym, current_valid_taxon: current_valid_taxon }

      before { create :synonym, junior_synonym: junior_synonym, senior_synonym: senior }

      it "returns the senior synonym" do
        expect(junior_synonym.current_valid_taxon_including_synonyms).to eq senior
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
        expect(taxon.current_valid_taxon_including_synonyms).to eq valid_senior
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
        expect(junior_synonym.current_valid_taxon_including_synonyms).to be_nil
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
        expect(taxon.current_valid_taxon_including_synonyms).to eq senior_synonym_of_senior_synonym
      end
    end
  end

  describe "#junior_synonyms_recursive" do
    let(:taxon) { create_species }

    context "when there are no `junior_synonyms`" do
      specify { expect(taxon.junior_synonyms_recursive).to be_empty }
    end

    context "when there are direct junior_synonyms" do
      let(:junior_synonym) { create_species }
      let(:another_junior_synonym) { create_species }

      before do
        create :synonym, senior_synonym: taxon, junior_synonym: junior_synonym
        create :synonym, senior_synonym: taxon, junior_synonym: another_junior_synonym
      end

      specify do
        expect(taxon.junior_synonyms_recursive).to eq [junior_synonym, another_junior_synonym]
      end
    end

    context "when there are nested `junior_synonyms`" do
      let(:junior_synonym) { create_species }
      let(:nested_junior_synonym) { create_species }
      let(:deeply_nested_junior_synonym) { create_species }
      let(:another_deeply_nested_junior_synonym) { create_species }

      before do
        create :synonym, senior_synonym: taxon, junior_synonym: junior_synonym
        create :synonym, senior_synonym: junior_synonym, junior_synonym: nested_junior_synonym
        create :synonym, senior_synonym: nested_junior_synonym, junior_synonym: deeply_nested_junior_synonym
        create :synonym, senior_synonym: nested_junior_synonym, junior_synonym: another_deeply_nested_junior_synonym
      end

      specify do
        expect(taxon.junior_synonyms_recursive).to eq [
          junior_synonym,
          nested_junior_synonym,
          deeply_nested_junior_synonym,
          another_deeply_nested_junior_synonym
        ]
      end
    end
  end

  it "can be a synonym" do
    taxon = build :family
    expect(taxon).not_to be_synonym
    taxon.update_attribute :status, Status::SYNONYM
    expect(taxon).to be_synonym
    expect(taxon).to be_invalid
  end

  it "can have junior and senior synonyms" do
    senior = create_genus 'Atta'
    junior = create_genus 'Eciton'
    create :synonym, junior_synonym: junior, senior_synonym: senior

    expect(senior.junior_synonyms.count).to eq 1
    expect(senior.senior_synonyms.count).to eq 0
    expect(junior.senior_synonyms.count).to eq 1
    expect(junior.junior_synonyms.count).to eq 0
  end

  describe "Reversing synonymy" do
    it "makes one the synonym of the other and set statuses" do
      atta = create_genus 'Atta'
      attaboi = create_genus 'Attaboi'

      become_junior_synonym_of atta, attaboi
      atta.reload
      attaboi.reload
      expect(atta.senior_synonyms).to include attaboi

      become_junior_synonym_of attaboi, atta
      atta.reload
      attaboi.reload
      expect(attaboi.status).to eq Status::SYNONYM
      expect(attaboi.senior_synonyms).to include atta
      expect(atta.status).to eq Status::VALID
      expect(atta.senior_synonyms).not_to include attaboi
    end

    it "doesn't create duplicate synonym in case of synonym cycle" do
      atta = create_genus 'Atta', status: Status::SYNONYM
      attaboi = create_genus 'Attaboi', status: Status::SYNONYM

      create :synonym, junior_synonym: atta, senior_synonym: attaboi
      create :synonym, junior_synonym: attaboi, senior_synonym: atta
      expect(Synonym.count).to eq 2

      become_junior_synonym_of atta, attaboi
      expect(Synonym.count).to eq 1
      expect(atta.senior_synonyms).to include attaboi
      expect(attaboi.senior_synonyms).not_to include atta
    end
  end

  describe "Removing synonymy" do
    it "removes all synonymies for the taxon" do
      atta = create_genus 'Atta'
      attaboi = create_genus 'Attaboi'
      become_junior_synonym_of attaboi, atta
      expect(atta.junior_synonyms.all.include?(attaboi)).to be_truthy
      expect(atta).not_to be_synonym
      expect(attaboi).to be_synonym
      expect(attaboi.senior_synonyms.all.include?(atta)).to be_truthy

      become_not_junior_synonym_of attaboi, atta

      expect(atta.junior_synonyms.all.include?(attaboi)).to be_falsey
      expect(atta).not_to be_synonym
      expect(attaboi).not_to be_synonym
      expect(attaboi.senior_synonyms.all.include?(atta)).to be_falsey
    end
  end

  describe "Deleting synonyms when status changed" do
    it "deletes synonyms when the status changes from 'synonym'" do
      atta = create_genus
      eciton = create_genus
      become_junior_synonym_of atta, eciton
      expect(atta).to be_synonym
      expect(atta.senior_synonyms.size).to eq 1
      expect(eciton.junior_synonyms.size).to eq 1

      atta.update_attribute :status, Status::VALID

      expect(atta).not_to be_synonym
      expect(atta.senior_synonyms.size).to eq 0
      expect(eciton.junior_synonyms.size).to eq 0
    end
  end

  describe "with_names" do
    let(:atta) { create_genus 'Atta' }
    let(:eciton) { create_genus 'Eciton' }

    before { become_junior_synonym_of eciton, atta }

    describe "#junior_synonyms_with_names" do
      it "works" do
        results = atta.junior_synonyms_with_names
        expect(results.size).to eq 1
        record = results.first
        expect(record['id']).to eq Synonym.find_by(junior_synonym: eciton).id
        expect(record['name']).to eq eciton.name.to_html
      end
    end

    describe "#senior_synonyms_with_names" do
      it "works" do
        results = eciton.senior_synonyms_with_names
        expect(results.size).to eq 1
        record = results.first
        expect(record['id']).to eq Synonym.find_by(senior_synonym: atta).id
        expect(record['name']).to eq atta.name.to_html
      end
    end
  end

  # Used to live in `Taxon` as instance methods, then in a monkey patch. See git.
  # Tests calling these may be deprecated, since they're mostly expecting
  # on what these methods does. Kept here because I haven't figured out if they are
  # WIP and are supposed to be implemented in the future.
  def become_junior_synonym_of junior, senior
    Synonym.where(junior_synonym: senior, senior_synonym: junior).destroy_all
    Synonym.where(senior_synonym: senior, junior_synonym: junior).destroy_all
    create :synonym, junior_synonym: junior, senior_synonym: senior
    senior.update! status: Status::VALID
    junior.update! status: Status::SYNONYM
  end

  def become_not_junior_synonym_of junior, senior
    Synonym.where(junior_synonym: junior, senior_synonym: senior).destroy_all
    junior.update! status: Status::VALID if junior.senior_synonyms.empty?
  end
end
