# frozen_string_literal: true

require 'rails_helper'

describe Exporters::Endnote::Formatter do
  describe '#call' do
    it "formats a `BookReference` correctly" do
      reference = create :book_reference,
        author_names: [create(:author_name, name: 'Bolton, B.'), create(:author_name, name: 'Fisher, B.L.')],
        title: 'Ants Are My Life',
        citation_year: '1933',
        publisher: create(:publisher, name: 'Springer Verlag', place: 'Dresden'),
        pagination: 'ix + 33pp.'
      expect(described_class[[reference]]).to eq %(%0 Book
%A Bolton, B.
%A Fisher, B.L.
%D 1933
%T Ants Are My Life
%C Dresden
%I Springer Verlag
%P ix + 33pp.
%~ AntCat

)
    end

    it "formats an `ArticleReference` correctly" do
      reference = create :article_reference,
        author_names: [create(:author_name, name: 'MacKay, W.')],
        citation_year: '1941',
        title: 'A title',
        journal: create(:journal, name: 'Psyche'),
        series_volume_issue: '1(2)',
        pagination: '3-4'
      reference.create_document url: 'http://antcat.org/article.pdf'
      expect(described_class[[reference]]).to eq %{%0 Journal Article
%A MacKay, W.
%D 1941
%T A title
%J Psyche
%N 1(2)
%P 3-4
%U http://antcat.org/article.pdf
%~ AntCat

}
    end

    it "strips out the italics formatting" do
      reference = create :article_reference,
        author_names: [create(:author_name, name: 'MacKay, W.')],
        citation_year: '1941',
        title: '*A title*',
        journal: create(:journal, name: 'Psyche'),
        series_volume_issue: '1(2)',
        pagination: '3-4'
      expect(described_class[[reference]]).to eq %{%0 Journal Article
%A MacKay, W.
%D 1941
%T A title
%J Psyche
%N 1(2)
%P 3-4
%~ AntCat

}
    end

    it "exports public and taxonomic notes" do
      reference = create :article_reference,
        author_names: [create(:author_name, name: 'MacKay, W.')],
        citation_year: '1941',
        title: '*A title*',
        journal: create(:journal, name: 'Psyche'),
        series_volume_issue: '1(2)',
        pagination: '3-4',
        public_notes: 'Public notes.',
        taxonomic_notes: 'Taxonomic notes'
      expect(described_class[[reference]]).to eq %{%0 Journal Article
%A MacKay, W.
%D 1941
%T A title
%J Psyche
%N 1(2)
%P 3-4
%Z Public notes.
%K Taxonomic notes
%~ AntCat

}
    end

    it "doesn't output `NestedReference`s" do
      reference = create :nested_reference
      expect(described_class[[reference]]).to eq "\n"
    end
  end
end
