require 'spec_helper'

describe Reference do
  let(:ward_ps) { create :author_name, name: 'Ward, P.S.' }
  let(:fisher_bl) { create :author_name, name: 'Fisher, B.L.' }

  it { is_expected.to be_versioned }
  it { is_expected.to validate_presence_of :title }

  describe "scopes" do
    let(:bolton_b) { create :author_name, name: 'Bolton, B.' }

    describe ".sorted_by_principal_author_last_name" do
      let!(:bolton_reference) { create :article_reference, author_names: [bolton_b, ward_ps] }
      let!(:ward_reference) { create :article_reference, author_names: [ward_ps, bolton_b] }
      let!(:fisher_reference) { create :article_reference, author_names: [fisher_bl, bolton_b] }

      it "orders by author_name" do
        expect(described_class.sorted_by_principal_author_last_name).
          to eq [bolton_reference, fisher_reference, ward_reference]
      end
    end

    describe ".unreviewed_references" do
      let!(:unreviewed) { create :article_reference, review_state: "reviewing" }

      before { create :article_reference, review_state: "reviewed" }

      it "returns unreviewed references" do
        expect(described_class.unreviewed).to eq [unreviewed]
      end
    end

    describe ".order_by_author_names_and_year" do
      it "sorts by author_name plus year plus letter" do
        fisher1910b = reference_factory author_name: 'Fisher', citation_year: '1910b'
        wheeler1874 = reference_factory author_name: 'Wheeler', citation_year: '1874'
        fisher1910a = reference_factory author_name: 'Fisher', citation_year: '1910a'

        expect(described_class.order_by_author_names_and_year).
          to eq [fisher1910a, fisher1910b, wheeler1874]
      end
    end
  end

  describe "#parse_author_names_and_suffix" do
    let(:reference) { build_stubbed :reference }

    context 'when input in empty' do
      it "returns nothing" do
        expect(reference.parse_author_names_and_suffix('')).
          to eq author_names: [], author_names_suffix: nil
      end
    end

    context 'when input is invalid' do
      it "adds an error and raise an exception" do
        expect { reference.parse_author_names_and_suffix('...asdf sdf dsfdsf') }.
          to raise_error ActiveRecord::RecordInvalid
        expect(reference.errors.messages).to eq author_names_string: ["couldn't be parsed."]
        expect(reference.author_names_string).to eq '...asdf sdf dsfdsf'
      end
    end

    context 'when input is present and valid' do
      it "returns the author names and the suffix" do
        results = reference.parse_author_names_and_suffix 'Fisher, B.; Bolton, B. (eds.)'
        fisher = AuthorName.find_by(name: 'Fisher, B.')
        bolton = AuthorName.find_by(name: 'Bolton, B.')

        expect(results).to eq author_names: [fisher, bolton], author_names_suffix: ' (eds.)'
      end
    end
  end

  describe "#author_names_string" do
    describe "formatting" do
      it "consists of one author_name if that's all there is" do
        reference = build_stubbed :reference, author_names: [fisher_bl]
        expect(reference.author_names_string).to eq 'Fisher, B.L.'
      end

      it "separates multiple author_names with semicolons" do
        reference = build_stubbed :reference, author_names: [fisher_bl, ward_ps]
        expect(reference.author_names_string).to eq 'Fisher, B.L.; Ward, P.S.'
      end

      it "includes the author_names' suffix" do
        reference = create :reference, author_names: [fisher_bl], author_names_suffix: ' (ed.)'
        expect(reference.reload.author_names_string).to eq 'Fisher, B.L. (ed.)'
      end
    end

    describe "updating, when things change" do
      let(:reference) { create :reference, author_names: [fisher_bl] }

      context "when an author_name is added" do
        before { reference.author_names << ward_ps }

        it "updates its `author_names_string`" do
          expect(reference.author_names_string).to eq 'Fisher, B.L.; Ward, P.S.'
        end
      end

      context "when an author_name is removed" do
        before { reference.author_names << ward_ps }

        it "updates its `author_names_string`" do
          expect { reference.author_names.delete ward_ps }.
            to change { reference.reload.author_names_string }.
            from('Fisher, B.L.; Ward, P.S.').to('Fisher, B.L.')
        end
      end

      context "when an author_name's name is changed" do
        before { reference.author_names = [ward_ps] }

        it "updates its `author_names_string`" do
          expect { ward_ps.update name: 'Fisher' }.
            to change { reference.reload.author_names_string }.
            from('Ward, P.S.').to('Fisher')
        end
      end

      context "when `author_names_suffix` changes" do
        before { reference.update author_names_suffix: ' (eds.)' }

        it "updates its `author_names_string`" do
          expect(reference.reload.author_names_string).to eq 'Fisher, B.L. (eds.)'
        end
      end
    end

    it "maintains the order in which they were added to the reference" do
      reference = create :reference, author_names: [ward_ps]
      fisher = create :author_name, name: 'Fisher'
      wilden = create :author_name, name: 'Wilden'
      reference.author_names << wilden
      reference.author_names << fisher

      expect(reference.author_names_string).to eq 'Ward, P.S.; Wilden; Fisher'
    end
  end

  describe "#principal_author_last_name_cache" do
    context "when there are no authors" do
      let!(:reference) { create :reference, author_names: [] }

      it "is nil" do
        expect(reference.principal_author_last_name_cache).to be_nil
      end
    end

    context 'when there are authors' do
      let!(:reference) { create :reference, author_names: [ward_ps, fisher_bl] }

      it "is the last name of the principal author" do
        expect(reference.principal_author_last_name_cache).to eq 'Ward'
      end
    end

    context "when an author_name's name is changed" do
      let!(:reference) { create :reference, author_names: [ward_ps] }

      it "updates its `principal_author_last_name_cache`" do
        expect { ward_ps.update name: 'Bolton, B.' }.
          to change { reference.reload.principal_author_last_name_cache }.from('Ward').to('Bolton')
      end
    end
  end

  describe "changing `citation_year`" do
    context 'when `citation_year` contains a letter' do
      let(:reference) { create :reference, citation_year: '1910a' }

      it "sets `year` to the stated year, if present" do
        expect { reference.update! citation_year: '2010b' }.
          to change { reference.reload.year }.from(1910).to(2010)
      end
    end

    context 'when `citation_year` contains a bracketed year' do
      let(:reference) { create :reference, citation_year: '1910a ["1958"]' }

      it "sets `year` to the stated year, if present" do
        expect { reference.update! citation_year: '2010b ["2009"]' }.
          to change { reference.reload.year }.from(1958).to(2009)
      end
    end

    context 'when `citation_year` is nil' do
      let(:reference) { create :reference, citation_year: nil }

      specify { expect(reference.short_citation_year).to eq "[no year]" }
    end
  end

  describe "shared setup" do
    let(:reference_params) do
      {
        author_names: [fisher_bl],
        citation_year: '1981',
        title: 'Dolichoderinae',
        journal: create(:journal),
        series_volume_issue: '1(2)',
        pagination: '22-54'
      }
    end
    let!(:original) { ArticleReference.create! reference_params }

    describe 'implementing MatchReferences' do
      it 'maps all fields correctly' do
        expect(original.principal_author_last_name_cache).to eq 'Fisher'
        expect(original.year).to eq 1981
        expect(original.title).to eq 'Dolichoderinae'
        expect(original.type).to eq 'ArticleReference'
        expect(original.series_volume_issue).to eq '1(2)'
        expect(original.pagination).to eq '22-54'
      end
    end

    describe "duplicate checking" do
      it "allows a duplicate record to be saved" do
        expect { ArticleReference.create! reference_params }.not_to raise_error
      end

      it "checks possible duplication and add to errors, if any found" do
        duplicate = ArticleReference.create! reference_params

        expect(duplicate.errors).to be_empty
        expect(duplicate.check_for_duplicate).to be_truthy
        expect(duplicate.errors).not_to be_empty
      end
    end
  end

  describe "#short_citation_year" do
    it "is the same as citation year if nothing extra" do
      reference = build_stubbed :article_reference, citation_year: '1970'
      expect(reference.short_citation_year).to eq '1970'
    end

    it "allows an ordinal letter" do
      reference = build_stubbed :article_reference, citation_year: '1970a'
      expect(reference.short_citation_year).to eq '1970a'
    end

    it "is trimmed if there is something extra" do
      reference = build_stubbed :article_reference, citation_year: '1970a ("1971")'
      expect(reference.short_citation_year).to eq '1970a'
    end
  end

  describe "#what_links_here" do
    subject { create :article_reference }

    it "calls `References::WhatLinksHere`" do
      expect(References::WhatLinksHere).to receive(:new).
        with(subject, predicate: false).and_call_original
      subject.what_links_here
    end
  end

  describe "#keey" do
    let(:bolton) { create :author_name, name: 'Bolton, B.' }
    let(:fisher) { create :author_name, name: 'Fisher, B.' }

    context "when citation years with extra" do
      let(:reference) do
        create :article_reference, author_names: [bolton], citation_year: '1970a ("1971")'
      end

      specify { expect(reference.keey).to eq 'Bolton, 1970a' }
    end

    context 'when no authors' do
      let(:reference) do
        create :article_reference, author_names: [], citation_year: '1970a'
      end

      specify { expect(reference.keey).to eq '[no authors], 1970a' }
    end

    context 'when one author' do
      let(:reference) do
        create :article_reference, author_names: [bolton], citation_year: '1970a'
      end

      specify { expect(reference.keey).to eq 'Bolton, 1970a' }
    end

    context 'when two authors' do
      let(:reference) do
        create :article_reference, author_names: [bolton, fisher], citation_year: '1970a'
      end

      specify { expect(reference.keey).to eq 'Bolton & Fisher, 1970a' }
    end

    context 'when three authors' do
      let(:ward) { create :author_name, name: 'Ward, P.S.' }
      let(:reference) do
        create :article_reference, author_names: [bolton, fisher, ward], citation_year: '1970a'
      end

      specify { expect(reference.keey).to eq 'Bolton <i>et al.</i>, 1970a' }
      specify { expect(reference.keey).to be_html_safe }
    end
  end

  describe "#keey_without_letters_in_year" do
    it "doesn't include the year ordinal" do
      reference = reference_factory author_name: 'Bolton', citation_year: '1885g'
      expect(reference.keey_without_letters_in_year).to eq 'Bolton, 1885'
    end

    it "handles multiple authors" do
      reference = create :article_reference, citation_year: '2001', year: '2001',
        author_names: [create(:author_name, name: 'Bolton, B.'),
                        create(:author_name, name: 'Fisher, R.')]
      expect(reference.keey_without_letters_in_year).to eq 'Bolton & Fisher, 2001'
    end
  end
end
