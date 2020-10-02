# frozen_string_literal: true

require 'rails_helper'

describe Exporters::Endnote::Formatter do
  describe '#call' do
    context 'when reference has content in italics' do
      let(:reference) do
        create :article_reference, author_string: 'MacKay, W.', title: '*A title*', series_volume_issue: '1(2)'
      end

      it "strips out the italics formatting" do
        expect(described_class[[reference]]).to eq <<~STRING
          %0 Journal Article
          %A MacKay, W.
          %D #{reference.year}
          %T A title
          %J #{reference.journal.name}
          %N 1(2)
          %P #{reference.pagination}
          %~ AntCat

        STRING
      end
    end

    context 'when reference has public or taxonomic notes' do
      let(:reference) do
        create :article_reference, :with_notes, author_string: 'MacKay, W.',
          title: '*A title*', series_volume_issue: '1(2)'
      end

      it "exports notes" do
        expect(described_class[[reference]]).to eq <<~STRING
          %0 Journal Article
          %A MacKay, W.
          %D #{reference.year}
          %T A title
          %J #{reference.journal.name}
          %N 1(2)
          %P #{reference.pagination}
          %Z #{reference.public_notes}
          %K #{reference.taxonomic_notes}
          %~ AntCat

        STRING
      end
    end

    context 'when reference is a `BookReference`' do
      let(:reference) do
        create :book_reference, author_string: ['Bolton, B.', 'Fisher, B.L.'], title: 'Ants'
      end

      specify do
        expect(described_class[[reference]]).to eq <<~STRING
          %0 Book
          %A Bolton, B.
          %A Fisher, B.L.
          %D #{reference.year}
          %T Ants
          %C #{reference.publisher.place}
          %I #{reference.publisher.name}
          %P #{reference.pagination}
          %~ AntCat

        STRING
      end
    end

    context 'when reference is a `ArticleReference`' do
      let(:reference) do
        create :article_reference, author_string: 'MacKay, W.', title: 'A title', series_volume_issue: '1(2)'
      end

      before do
        reference.create_document url: 'http://antcat.org/article.pdf'
      end

      specify do
        expect(described_class[[reference]]).to eq <<~STRING
          %0 Journal Article
          %A MacKay, W.
          %D #{reference.year}
          %T A title
          %J #{reference.journal.name}
          %N 1(2)
          %P #{reference.pagination}
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
