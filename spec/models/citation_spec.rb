# coding: UTF-8
require 'spec_helper'

describe Citation do

  it "has a Reference" do
    reference = FactoryGirl.create :reference
    citation = Citation.create! :reference => reference
    citation.reload.reference.should == reference
  end

  it "does require a Reference" do
    citation = Citation.create
    citation.reference.should be_nil
    citation.should_not be_valid
  end

  describe "Versioning" do
    it "should record versions" do
      with_versioning do
        citation = FactoryGirl.create :citation
        citation.versions.last.event.should == 'create'
      end
    end
  end

  describe "Importing" do

    it "should create the Citation, which is linked to an existing Reference" do
      reference = FactoryGirl.create :article_reference, :bolton_key_cache => 'Latreille 1809a'
      data = {author_names: ['Latreille'], year: '1809a', pages: '124', forms: 'w.q.'}

      citation = Citation.import(data).reload

      citation.pages.should == '124'
      citation.reference.should == reference
      citation.forms.should == 'w.q.'
    end

    it "should link to a MissingReference, if necessary" do
      data = {:author_names => ["Latreille"], :year => "1809a", :pages => "124", :matched_text => 'Latreille, 1809a: 124'}
      citation = Citation.import(data).reload
      citation.pages.should == '124'
      missing_reference = citation.reference
      missing_reference.citation.should == 'Latreille, 1809a'
      missing_reference.reason_missing.should == 'no Bolton'
    end

    it "should handle a nested reference when the year is only with the parent" do
      reference = FactoryGirl.create :nested_reference, bolton_key_cache: 'Bolton 2004'
      data = {
        author_names: ['Latreille'],
        in: {
          author_names: ['Bolton'], year: '2004'
        },
        pages: '24'
      }

      citation = Citation.import(data).reload

      citation.pages.should == '24'
      citation.reference.should == reference
    end

    it "should handle a note" do
      data = {
        :author_names=>["Scudder"],
        :year=>"1877b",
        :pages=>"270",
        :notes=>
        [
          [
            {:phrase=>"as member of family", :delimiter=>" "},
            {:family_or_subfamily_name=>"Braconidae"},
            {:bracketed=>true}
          ]
        ],
        :matched_text=> "Scudder, 1877b: 270 [as member of family Braconidae]"
      }

      citation = Citation.import(data).reload
      citation.notes_taxt.should == " [as member of family {nam #{Name.find_by_name('Braconidae').id}}]"
    end

  end

  describe "Authorship string" do
    it "should show the author and year" do
      reference = reference_factory author_name: 'Bolton', citation_year: '2001'
      citation = FactoryGirl.build_stubbed :citation, reference: reference
      citation.authorship_string.should == 'Bolton, 2001'
    end
    it "should handle multiple authors" do
      reference = FactoryGirl.build_stubbed(:article_reference, author_names: [
        FactoryGirl.create(:author_name, :name => 'Bolton, B.'),
        FactoryGirl.create(:author_name, :name => 'Fisher, R.'),
      ], citation_year: '2001', year: '2001')
      citation = FactoryGirl.build_stubbed :citation, reference: reference
      citation.authorship_string.should == 'Bolton & Fisher, 2001'
    end
    it "should not include the year ordinal" do
      reference = reference_factory author_name: 'Bolton', citation_year: '1885g'
      citation = FactoryGirl.build_stubbed :citation, reference: reference
      citation.authorship_string.should == 'Bolton, 1885'
    end
  end

end
