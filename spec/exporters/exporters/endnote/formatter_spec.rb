# frozen_string_literal: true

require 'rails_helper'

describe Exporters::Endnote::Formatter do
  describe '#call' do
    context 'when reference has content in italics' do
      let(:reference) do
        create :article_reference,
          author_names: [create(:author_name, name: 'MacKay, W.')],
          citation_year: '1941',
          title: '*A title*',
          journal: create(:journal, name: 'Psyche'),
          series_volume_issue: '1(2)',
          pagination: '3-4'
      end

      it "strips out the italics formatting" do
        expect(described_class[[reference]]).to eq <<~STRING
          %0 Journal Article
          %A MacKay, W.
          %D 1941
          %T A title
          %J Psyche
          %N 1(2)
          %P 3-4
          %~ AntCat

        STRING
      end
    end

    context 'when reference has public or taxonomic notes' do
      let(:reference) do
        create :article_reference,
          author_names: [create(:author_name, name: 'MacKay, W.')],
          citation_year: '1941',
          title: '*A title*',
          journal: create(:journal, name: 'Psyche'),
          series_volume_issue: '1(2)',
          pagination: '3-4',
          public_notes: 'Public notes.',
          taxonomic_notes: 'Taxonomic notes'
      end

      it "exports notes" do
        expect(described_class[[reference]]).to eq <<~STRING
          %0 Journal Article
          %A MacKay, W.
          %D 1941
          %T A title
          %J Psyche
          %N 1(2)
          %P 3-4
          %Z Public notes.
          %K Taxonomic notes
          %~ AntCat

        STRING
      end
    end

    context 'when reference is a `BookReference`' do
      let(:reference) do
        create :book_reference,
          author_names: [create(:author_name, name: 'Bolton, B.'), create(:author_name, name: 'Fisher, B.L.')],
          title: 'Ants Are My Life',
          citation_year: '1933',
          publisher: create(:publisher, name: 'Springer Verlag', place: 'Dresden'),
          pagination: 'ix + 33pp.'
      end

      specify do
        expect(described_class[[reference]]).to eq <<~STRING
          %0 Book
          %A Bolton, B.
          %A Fisher, B.L.
          %D 1933
          %T Ants Are My Life
          %C Dresden
          %I Springer Verlag
          %P ix + 33pp.
          %~ AntCat

        STRING
      end
    end

    context 'when reference is a `ArticleReference`' do
      let(:reference) do
        create :article_reference,
          author_names: [create(:author_name, name: 'MacKay, W.')],
          citation_year: '1941',
          title: 'A title',
          journal: create(:journal, name: 'Psyche'),
          series_volume_issue: '1(2)',
          pagination: '3-4'
      end

      before do
        reference.create_document url: 'http://antcat.org/article.pdf'
      end

      specify do
        expect(described_class[[reference]]).to eq <<~STRING
          %0 Journal Article
          %A MacKay, W.
          %D 1941
          %T A title
          %J Psyche
          %N 1(2)
          %P 3-4
          %U http://antcat.org/article.pdf
          %~ AntCat

        STRING
      end
    end

    context 'when reference is a `NestedReference`' do
      let(:reference) { create :nested_reference }

      it "doesn't output anything" do
        expect(described_class[[reference]]).to eq "\n"
      end
    end
  end
end
