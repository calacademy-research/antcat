# frozen_string_literal: true

require 'rails_helper'

describe References::ReferenceSimilarity do
  describe '#call' do
    context "when type mismatch" do
      let(:lhs) { ArticleReference.new }
      let(:rhs) { NestedReference.new }

      it "never considers references of different types similar" do
        expect(described_class[lhs, rhs]).to eq 0.00
      end
    end

    describe "author + year matching" do
      context "when the author names don't match but the years do" do
        let(:lhs) { Reference.new(year: 2010) }
        let(:rhs) { Reference.new(year: 2010) }

        it "doesn't match if the author name is different" do
          expect(lhs).to receive(:author_names).and_return([build_stubbed(:author_name, name: 'Fisher')])
          expect(rhs).to receive(:author_names).and_return([build_stubbed(:author_name, name: 'Bolton')])

          expect(described_class[lhs, rhs]).to eq 0.00
        end

        it "doesn't match if the author name is a prefix" do
          expect(lhs).to receive(:author_names).and_return([build_stubbed(:author_name, name: 'Fisher')])
          expect(rhs).to receive(:author_names).and_return([build_stubbed(:author_name, name: 'Fish')])

          expect(described_class[lhs, rhs]).to eq 0.00
        end
      end

      context 'when author names match' do
        let(:lhs) { Reference.new(title: 'A') }
        let(:rhs) { Reference.new(title: 'B') }

        before do
          allow(lhs).to receive(:author_names).and_return([build_stubbed(:author_name, name: 'Fisher, B. L.')])
          allow(rhs).to receive(:author_names).and_return([build_stubbed(:author_name, name: 'Fisher, B. L.')])
        end

        it "doesn't match if the author name is the same but the year is different" do
          lhs.year = 1970
          rhs.year = 1980

          expect(described_class[lhs, rhs]).to eq 0.001
        end

        it "matches better if the author name matches and the year is within 1" do
          lhs.year = 1979
          rhs.year = 1980

          expect(described_class[lhs, rhs]).to eq 0.001
        end
      end

      context 'when author names almost match' do
        let(:lhs) { Reference.new(title: 'A', year: 1979) }
        let(:rhs) { Reference.new(title: 'B', year: 1980) }

        it "matches if the author names differ by accentation" do
          expect(lhs).to receive(:author_names).and_return([build_stubbed(:author_name, name: 'Csösz')])
          expect(rhs).to receive(:author_names).and_return([build_stubbed(:author_name, name: 'Csősz')])

          expect(described_class[lhs, rhs]).to eq 0.001
        end

        it "matches if the author names differ by case" do
          expect(lhs).to receive(:author_names).and_return([build_stubbed(:author_name, name: 'MacKay')])
          expect(rhs).to receive(:author_names).and_return([build_stubbed(:author_name, name: 'Mackay')])

          expect(described_class[lhs, rhs]).to eq 0.001
        end
      end
    end

    describe "title + year matching" do
      before do
        allow(lhs).to receive(:author_names).and_return([build_stubbed(:author_name, name: 'Fisher, B. L.')])
        allow(rhs).to receive(:author_names).and_return([build_stubbed(:author_name, name: 'Fisher, B. L.')])
      end

      context "when title is same" do
        let(:lhs) { Reference.new(title: 'Ants') }
        let(:rhs) { Reference.new(title: 'Ants') }

        it "matches with much less confidence if the author and title are the same but the year is not within 1" do
          lhs.year = 1975
          rhs.year = 1971

          expect(described_class[lhs, rhs]).to eq 0.50
        end
      end

      context "when year is within 1" do
        let(:lhs) { Reference.new(year: 1979) }
        let(:rhs) { Reference.new(year: 1980) }

        it "matches with complete confidence if the author and title are the same" do
          lhs.title = 'Ants'
          rhs.title = 'Ants'

          expect(described_class[lhs, rhs]).to eq 1.00
        end

        it "matches when lhs includes taxon names, as long as one of them is one we know about" do
          rhs.title = 'Symphyta and their type species'
          lhs.title = 'Symphyta (Hymenoptera: Formicidae) and their type species'

          expect(described_class[lhs, rhs]).to eq 1.00
        end

        it "doesn't match when the only difference is parenthetical, but is not a taxon name" do
          rhs.title = 'Symphyta and their type species'
          lhs.title = 'Symphyta (unknown) and their type species'

          expect(described_class[lhs, rhs]).to eq 0.001
        end

        it "matches when the only difference is accents" do
          rhs.title = 'Sobre su taxonomia'
          lhs.title = 'Sobre su taxonomía'

          expect(described_class[lhs, rhs]).to eq 1.00
        end

        it "matches when the only difference is case" do
          rhs.title = 'Ants'
          lhs.title = 'ANTS'

          expect(described_class[lhs, rhs]).to eq 1.00
        end

        it "matches when the only difference is punctuation" do
          rhs.title = 'Morfólogicos de Goniomma'
          lhs.title = 'Morfólogicos de *Goniomma*'

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

          expect(described_class[lhs, rhs]).to eq 0.001
        end

        describe 'replacing Roman numerals with Arabic' do
          it "doesn't replace Roman numerals embedded in words" do
            rhs.title = 'Indigenous'
            lhs.title = '1ndigenous'

            expect(described_class[lhs, rhs]).to eq 0.001
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
      let(:lhs) { BookReference.new(title: 'Myrmicinae', pagination: '1-76') }
      let(:rhs) { BookReference.new(title: 'Formica', pagination: '1-76') }

      before do
        allow(lhs).to receive(:author_names).and_return([build_stubbed(:author_name, name: 'Fisher')])
        allow(rhs).to receive(:author_names).and_return([build_stubbed(:author_name, name: 'Fisher')])
      end

      it 'matches with much less confidence when the year does not match' do
        lhs.year = 1971
        rhs.year = 1980

        expect(described_class[lhs, rhs]).to be_within(0.001).of(0.30)
      end

      it "matches perfectly when the year does match" do
        lhs.year = 1979
        rhs.year = 1980

        expect(described_class[lhs, rhs]).to eq 0.80
      end
    end

    describe 'matching series/volume/issue + pagination with different titles' do
      before do
        allow(lhs).to receive(:author_names).and_return([build_stubbed(:author_name, name: 'Fisher')])
        allow(rhs).to receive(:author_names).and_return([build_stubbed(:author_name, name: 'Fisher')])
      end

      context 'when the pagination matches' do
        context 'when the year does not match' do
          let(:lhs) { ArticleReference.new(title: 'Myrmicinae', pagination: '1-76', series_volume_issue: '(21) 4') }
          let(:rhs) { ArticleReference.new(title: 'Formica', pagination: '1-76', series_volume_issue: '(21) 4') }

          it 'matches with much less confidence' do
            lhs.year = 1980
            rhs.year = 1990

            expect(described_class[lhs, rhs]).to eq 0.40
          end
        end

        context 'when the year matches' do
          let(:lhs) { ArticleReference.new(title: 'Myrmicinae', pagination: '1-76', year: 1979) }
          let(:rhs) { ArticleReference.new(title: 'Formica', pagination: '1-76', year: 1980) }

          it "matches a perfect match" do
            lhs.series_volume_issue = '(21) 4'
            rhs.series_volume_issue = '(21) 4'

            expect(described_class[lhs, rhs]).to eq 0.90
          end

          it "matches when the series/volume/issue has spaces after the volume (issue first)" do
            lhs.series_volume_issue = '(21)4'
            rhs.series_volume_issue = '(21) 4'

            expect(described_class[lhs, rhs]).to eq 0.90
          end

          it "matches when the series/volume/issue has spaces after the volume (issue last)" do
            lhs.series_volume_issue = '4(21)'
            rhs.series_volume_issue = '4 (21)'

            expect(described_class[lhs, rhs]).to eq 0.90
          end

          context "when the series/volume/issue has a space after the series, but the space separates words" do
            it "doesn't match the series_volume_issue" do
              lhs.series_volume_issue = '21 4'
              rhs.series_volume_issue = '214'

              expect(described_class[lhs, rhs]).to eq 0.001
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
      let(:lhs) { ArticleReference.new(title: 'Ant', pagination: '8-9', series_volume_issue: '1', year: 2002) }
      let(:rhs) { ArticleReference.new(title: 'Ant', pagination: '1-7', series_volume_issue: '1', year: 2002) }

      before do
        allow(lhs).to receive(:author_names).and_return([build_stubbed(:author_name, name: 'Fisher')])
        allow(rhs).to receive(:author_names).and_return([build_stubbed(:author_name, name: 'Fisher')])
      end

      it "gives it a 0.99" do
        expect(described_class[lhs, rhs]).to eq 0.99
      end
    end
  end
end
