require 'spec_helper'

describe References::ReferenceSimilarity do
  context "when type mismatch" do
    let(:lhs) { ArticleReference.new title: 'Ants', year: '1975' }
    let(:rhs) { NestedReference.new title: 'Ants', year: '1975' }

    before do
      lhs.principal_author_last_name_cache = 'Fisher, B. L.'
      rhs.principal_author_last_name_cache = 'Fisher, B. L.'
    end

    it "never considers references of different types similar in the least" do
      expect(described_class[lhs, rhs]).to eq 0.00
    end
  end

  describe "author + year matching" do
    context "when the author names don't match but the years do" do
      let(:lhs) { Reference.new year: 2010 }
      let(:rhs) { Reference.new year: 2010 }

      it "doesn't match if the author name is different" do
        lhs.principal_author_last_name_cache = 'Fisher'
        rhs.principal_author_last_name_cache = 'Bolton'
        expect(described_class[lhs, rhs]).to eq 0.00
      end

      it "doesn't match if the author name is a prefix" do
        lhs.principal_author_last_name_cache = 'Fisher'
        rhs.principal_author_last_name_cache = 'Fish'
        expect(described_class[lhs, rhs]).to eq 0.00
      end
    end

    context 'when the author names match' do
      let(:lhs) { Reference.new title: 'A' }
      let(:rhs) { Reference.new title: 'B' }

      before do
        lhs.principal_author_last_name_cache = 'Fisher, B. L.'
        rhs.principal_author_last_name_cache = 'Fisher, B. L.'
      end

      it "doesn't match if the author name is the same but the year is different" do
        lhs.year = '1970'
        rhs.year = '1980'
        expect(described_class[lhs, rhs]).to eq 0.00
      end

      it "matches better if the author name matches and the year is within 1" do
        lhs.year = '1979'
        rhs.year = '1980'
        expect(described_class[lhs, rhs]).to eq 0.10
      end

      it "matches if the author names differ by accentation" do
        lhs.principal_author_last_name_cache = 'Csösz'
        lhs.year = '1979'
        rhs.principal_author_last_name_cache = 'Csősz'
        rhs.year = '1980'

        expect(described_class[lhs, rhs]).to eq 0.10
      end

      it "matches if the author names differ by case" do
        lhs.principal_author_last_name_cache = 'MacKay'
        lhs.year = '1979'
        rhs.principal_author_last_name_cache = 'Mackay'
        rhs.year = '1980'

        expect(described_class[lhs, rhs]).to eq 0.10
      end
    end
  end

  describe "title + year matching" do
    let(:lhs) { Reference.new }
    let(:rhs) { Reference.new }

    before do
      lhs.principal_author_last_name_cache = 'Fisher, B. L.'
      rhs.principal_author_last_name_cache = 'Fisher, B. L.'
    end

    it "matches with much less confidence if the author and title are the same but the year is not within 1" do
      lhs.title = 'Ants'
      lhs.year = '1975'
      rhs.title = 'Ants'
      rhs.year = '1971'

      expect(described_class[lhs, rhs]).to eq 0.50
    end

    context "when year is within 1" do
      before do
        lhs.year = '1979'
        rhs.year = '1980'
      end

      it "matches with complete confidence if the author and title are the same" do
        lhs.title = 'Ants'
        rhs.title = 'Ants'
        expect(described_class[lhs, rhs]).to eq 1.00
      end

      it "matches when lhs includes taxon names, as long as one of them is one we know about" do
        rhs.title = 'The genus-group names of Symphyta and their type species'
        lhs.title = 'The genus-group names of Symphyta (Hymenoptera: Formicidae) and their type species'
        expect(described_class[lhs, rhs]).to eq 1.00
      end

      it "doesn't match when the only difference is parenthetical, but is not a toxon name" do
        rhs.title = 'The genus-group names of Symphyta and their type species'
        lhs.title = 'The genus-group names of Symphyta (unknown) and their type species'
        expect(described_class[lhs, rhs]).to eq 0.10
      end

      it "matches when the only difference is accents" do
        rhs.title = 'Sobre los caracteres morfólogicos de Goniomma, con algunas sugerencias sobre su taxonomia'
        lhs.title = 'Sobre los caracteres morfólogicos de Goniomma, con algunas sugerencias sobre su taxonomía'
        expect(described_class[lhs, rhs]).to eq 1.00
      end

      it "matches when the only difference is case" do
        rhs.title = 'Ants'
        lhs.title = 'ANTS'
        expect(described_class[lhs, rhs]).to eq 1.00
      end

      it "matches when the only difference is punctuation" do
        rhs.title = 'Morfólogicos de Goniomma, con algunas sugerencias'
        lhs.title = 'Morfólogicos de *Goniomma*, con algunas sugerencias'
        expect(described_class[lhs, rhs]).to eq 1.00
      end

      it "matches when the only difference is in square brackets" do
        rhs.title = 'Ants [sic] and pants'
        lhs.title = 'Ants and pants [sic]'
        expect(described_class[lhs, rhs]).to eq 0.95
      end

      it "doesn't match when the whole title is square brackets" do
        rhs.title = '[Ants and pants]'
        lhs.title = '[Pants and ants]'
        expect(described_class[lhs, rhs]).to eq 0.10
      end

      describe 'replacing Roman numerals with Arabic' do
        it "doesn't replace Roman numerals embedded in words" do
          rhs.title = 'Indigenous'
          lhs.title = '1ndigenous'
          expect(described_class[lhs, rhs]).to eq 0.10
        end

        it "matches with a little less confidence when Roman numerals are replaced with Arabic" do
          rhs.title = 'Volume 1.'
          lhs.title = 'Volume I.'
          expect(described_class[lhs, rhs]).to eq 0.94
        end

        it "replaces the longest Roman numeral" do
          rhs.title = 'Volume IV.'
          lhs.title = 'Volume 4.'
          expect(described_class[lhs, rhs]).to eq 0.94
        end
      end
    end
  end

  describe 'matching book pagination with different titles' do
    let(:lhs) { BookReference.new title: 'Myrmicinae', pagination: '1-76' }
    let(:rhs) { BookReference.new title: 'Formica', pagination: '1-76' }

    before do
      lhs.principal_author_last_name_cache = 'Fisher'
      rhs.principal_author_last_name_cache = 'Fisher'
    end

    it 'matches with much less confidence when the year does not match' do
      lhs.year = '1980'
      rhs.year = '1990'
      expect(described_class[lhs, rhs]).to be_within(0.001).of(0.30)
    end

    it "matches perfectly when the year does match" do
      lhs.year = '1979'
      rhs.year = '1980'
      expect(described_class[lhs, rhs]).to eq 0.80
    end
  end

  describe 'matching series/volume/issue + pagination with different titles' do
    let(:lhs) { ArticleReference.new title: 'Myrmicinae' }
    let(:rhs) { ArticleReference.new title: 'Formica' }

    before do
      lhs.principal_author_last_name_cache = 'Fisher'
      rhs.principal_author_last_name_cache = 'Fisher'
    end

    context 'when the pagination matches' do
      before do
        lhs.pagination = '1-76'
        rhs.pagination = '1-76'
      end

      context 'when the year does not match' do
        it 'matches with much less confidence' do
          lhs.year = '1980'
          lhs.series_volume_issue = '(21) 4'
          rhs.year = '1990'
          rhs.series_volume_issue = '(21) 4'

          expect(described_class[lhs, rhs]).to eq 0.40
        end
      end

      context 'when the year matches' do
        before do
          lhs.year = '1979'
          rhs.year = '1980'
        end

        it "matches a perfect match" do
          lhs.series_volume_issue = '(21) 4'
          rhs.series_volume_issue = '(21) 4'
          expect(described_class[lhs, rhs]).to eq 0.90
        end

        it "matches when the series/volume/issue has spaces after the volume" do
          lhs.series_volume_issue = '(21)4'
          rhs.series_volume_issue = '(21) 4'
          expect(described_class[lhs, rhs]).to eq 0.90
        end

        it "matches when the series/volume/issue has spaces after the volume" do
          lhs.series_volume_issue = '4(21)'
          rhs.series_volume_issue = '4 (21)'
          expect(described_class[lhs, rhs]).to eq 0.90
        end

        context "when the series/volume/issue has a space after the series, but the space separates words" do
          it "doesn't match the series_volume_issue" do
            lhs.series_volume_issue = '21 4'
            rhs.series_volume_issue = '214'
            expect(described_class[lhs, rhs]).to eq 0.10
          end
        end

        it "matches if the only difference is that rhs includes the year" do
          lhs.series_volume_issue = '44'
          rhs.series_volume_issue = '44 (1976)'
          expect(described_class[lhs, rhs]).to eq 0.90
        end

        it "matches if the only difference is that rhs uses 'No.'" do
          lhs.series_volume_issue = '1976(1)'
          rhs.series_volume_issue = '1976 (No. 1)'
          expect(described_class[lhs, rhs]).to eq 0.90
        end

        it "matches if the only difference is punctuation" do
          lhs.series_volume_issue = ') 15'
          rhs.series_volume_issue = '15'
          expect(described_class[lhs, rhs]).to eq 0.90
        end
      end
    end
  end

  describe 'matching everything except the pagination' do
    let(:lhs) do
      ArticleReference.new title: 'Myrmicinae',
        pagination: '29-30', series_volume_issue: '1', year: '2002'
    end
    let(:rhs) do
      ArticleReference.new title: 'Myrmicinae',
        pagination: '15-19', series_volume_issue: '1', year: '2002'
    end

    before do
      lhs.principal_author_last_name_cache = 'Fisher'
      rhs.principal_author_last_name_cache = 'Fisher'
    end

    it "gives it a 0.99" do
      expect(described_class[lhs, rhs]).to eq 0.99
    end
  end
end
