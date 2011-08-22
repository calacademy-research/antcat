require 'spec_helper'

describe ReferenceFormatter::EndnoteImport do

  it "should format a book reference correctly" do
    reference = Factory :book_reference,
      :author_names => [Factory(:author_name, :name => 'Bolton, B.')],
      :title => 'Ants Are My Life',
      :citation_year => '1933',
      :publisher => Factory(:publisher, :name => 'Springer Verlag', :place => Factory(:place, :name => 'Dresden')),
      :pagination => 'ix + 33pp.'
    ReferenceFormatter::EndnoteImport.format([reference]).should ==
%{%0 Book
%A Bolton, B.
%D 1933
%T Ants Are My Life
%C Dresden
%I Springer Verlag
%P ix + 33pp.
%~ AntCat

}
  end

  it "should format multiple authors correctly" do
    reference = Factory :book_reference,
      :author_names => [Factory(:author_name, :name => 'Bolton, B.'), Factory(:author_name, :name => 'Fisher, B.L.')],
      :title => 'Ants Are My Life',
      :citation_year => '1933',
      :publisher => Factory(:publisher, :name => 'Springer Verlag', :place => Factory(:place, :name => 'Dresden')),
      :pagination => 'ix + 33pp.'
    ReferenceFormatter::EndnoteImport.format([reference]).should ==
%{%0 Book
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

  it "should not emit %A if there is no author" do
    reference = Factory :book_reference,
      :author_names => [],
      :title => 'Ants Are My Life',
      :citation_year => '1933',
      :publisher => Factory(:publisher, :name => 'Springer Verlag', :place => Factory(:place, :name => 'Dresden')),
      :pagination => 'ix + 33pp.'
    ReferenceFormatter::EndnoteImport.format([reference]).should ==
%{%0 Book
%D 1933
%T Ants Are My Life
%C Dresden
%I Springer Verlag
%P ix + 33pp.
%~ AntCat

}
  end

  it "should format a article reference correctly" do
    reference = Factory :article_reference,
      :author_names => [Factory(:author_name, :name => 'MacKay, W.')],
      :citation_year => '1941',
      :title => 'A title',
      :journal => Factory(:journal, :name => 'Psyche'),
      :series_volume_issue => '1(2)',
      :pagination => '3-4'
    reference.create_document :url => 'http://antcat.org/article.pdf'
    string = ReferenceFormatter::EndnoteImport.format([reference])
    string.should == 
%{%0 Journal Article
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

  it "should strip out the italics formatting" do
    reference = Factory :article_reference,
      :author_names => [Factory(:author_name, :name => 'MacKay, W.')],
      :citation_year => '1941',
      :title => '*A title*',
      :journal => Factory(:journal, :name => 'Psyche'),
      :series_volume_issue => '1(2)',
      :pagination => '3-4'
    ReferenceFormatter::EndnoteImport.format([reference]).should ==
%{%0 Journal Article
%A MacKay, W.
%D 1941
%T A title
%J Psyche
%N 1(2)
%P 3-4
%~ AntCat

}
  end

  it "should export public and taxonomic notes" do
    reference = Factory :article_reference,
      :author_names => [Factory(:author_name, :name => 'MacKay, W.')],
      :citation_year => '1941',
      :title => '*A title*',
      :journal => Factory(:journal, :name => 'Psyche'),
      :series_volume_issue => '1(2)',
      :pagination => '3-4',
      :public_notes => 'Public notes.',
      :taxonomic_notes => 'Taxonomic notes'
    ReferenceFormatter::EndnoteImport.format([reference]).should ==
%{%0 Journal Article
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

  it "should not export blank public and taxonomic notes" do
    reference = Factory :article_reference,
      :author_names => [Factory(:author_name, :name => 'MacKay, W.')],
      :citation_year => '1941',
      :title => '*A title*',
      :journal => Factory(:journal, :name => 'Psyche'),
      :series_volume_issue => '1(2)',
      :pagination => '3-4',
      :public_notes => '',
      :taxonomic_notes => ''
    ReferenceFormatter::EndnoteImport.format([reference]).should ==
%{%0 Journal Article
%A MacKay, W.
%D 1941
%T A title
%J Psyche
%N 1(2)
%P 3-4
%~ AntCat

}
  end

  it "should bail on a class it doesn't know about " do
    lambda {ReferenceFormatter::EndnoteImport.format([String.new])}.should raise_error
  end

  it "should format an unknown reference correctly" do
    reference = Factory :unknown_reference,
      :author_names => [Factory(:author_name, :name => 'MacKay, W.')],
      :citation_year => '1933',
      :title => 'Another title',
      :citation => 'Dresden'
    ReferenceFormatter::EndnoteImport.format([reference]).should ==
%{%0 Generic
%A MacKay, W.
%D 1933
%T Another title
%1 Dresden
%~ AntCat

}
  end

  it "should not output nested references" do
    reference = Factory :nested_reference
    ReferenceFormatter::EndnoteImport.format([reference]).should == "\n"
  end

end
