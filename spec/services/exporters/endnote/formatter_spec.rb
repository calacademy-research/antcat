require 'spec_helper'

describe Exporters::Endnote::Formatter do
  subject(:formatter) { described_class }

  it "formats a book reference correctly" do
    reference = create :book_reference,
      author_names: [create(:author_name, name: 'Bolton, B.')],
      title: 'Ants Are My Life',
      citation_year: '1933',
      publisher: create(:publisher, name: 'Springer Verlag', place: create(:place, name: 'Dresden')),
      pagination: 'ix + 33pp.'
    expect(formatter.format([reference])).to eq %{%0 Book
%A Bolton, B.
%D 1933
%T Ants Are My Life
%C Dresden
%I Springer Verlag
%P ix + 33pp.
%~ AntCat

}
  end

  it "formats multiple authors correctly" do
    reference = create :book_reference,
      author_names: [create(:author_name, name: 'Bolton, B.'), create(:author_name, name: 'Fisher, B.L.')],
      title: 'Ants Are My Life',
      citation_year: '1933',
      publisher: create(:publisher, name: 'Springer Verlag', place: create(:place, name: 'Dresden')),
      pagination: 'ix + 33pp.'
    expect(formatter.format([reference])).to eq %{%0 Book
%A Bolton, B.
%A Fisher, B.L.
%D 1933
%T Ants Are My Life
%C Dresden
%I Springer Verlag
%P ix + 33pp.
%~ AntCat

}
  end

  it "doesn't emit %A if there is no author" do
    reference = create :book_reference,
      author_names: [],
      title: 'Ants Are My Life',
      citation_year: '1933',
      publisher: create(:publisher, name: 'Springer Verlag', place: create(:place, name: 'Dresden')),
      pagination: 'ix + 33pp.'
    expect(formatter.format([reference])).to eq %{%0 Book
%D 1933
%T Ants Are My Life
%C Dresden
%I Springer Verlag
%P ix + 33pp.
%~ AntCat

}
  end

  it "formats a article reference correctly" do
    reference = create :article_reference,
      author_names: [create(:author_name, name: 'MacKay, W.')],
      citation_year: '1941',
      title: 'A title',
      journal: create(:journal, name: 'Psyche'),
      series_volume_issue: '1(2)',
      pagination: '3-4'
    reference.create_document url: 'http://antcat.org/article.pdf'
    results = formatter.format [reference]
    expect(results).to eq %{%0 Journal Article
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
    expect(formatter.format([reference])).to eq %{%0 Journal Article
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
    expect(formatter.format([reference])).to eq %{%0 Journal Article
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

  it "doesn't export blank public and taxonomic notes" do
    reference = create :article_reference,
      author_names: [create(:author_name, name: 'MacKay, W.')],
      citation_year: '1941',
      title: '*A title*',
      journal: create(:journal, name: 'Psyche'),
      series_volume_issue: '1(2)',
      pagination: '3-4',
      public_notes: '',
      taxonomic_notes: ''
    expect(formatter.format([reference])).to eq %{%0 Journal Article
%A MacKay, W.
%D 1941
%T A title
%J Psyche
%N 1(2)
%P 3-4
%~ AntCat

}
  end

  it "bails on a class it doesn't know about " do
    expect { formatter.format([String.new]) }.
      to raise_error(/Don't know what kind of reference this is/)
  end

  it "formats an unknown reference correctly" do
    reference = create :unknown_reference,
      author_names: [create(:author_name, name: 'MacKay, W.')],
      citation_year: '1933',
      title: 'Another title',
      citation: 'Dresden'
    expect(formatter.format([reference])).to eq %{%0 Generic
%A MacKay, W.
%D 1933
%T Another title
%1 Dresden
%~ AntCat

}
  end

  it "doesn't output nested references" do
    reference = create :nested_reference
    expect(formatter.format([reference])).to eq "\n"
  end
end
