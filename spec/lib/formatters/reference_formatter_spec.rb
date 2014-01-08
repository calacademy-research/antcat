# coding: UTF-8
require 'spec_helper'

describe Formatters::ReferenceFormatter do
  before do
    @journal = FactoryGirl.create :journal, :name => "Neue Denkschriften"
    @author_name = FactoryGirl.create :author_name, :name => "Forel, A."
    @publisher = FactoryGirl.create :publisher
    @formatter = Formatters::ReferenceFormatter
  end

  describe "Making a string HTML-safe" do
    it "should not touch a string without HTML" do
      @formatter.make_html_safe('string').should == 'string'
    end
    it "should leave italics alone" do
      @formatter.make_html_safe('<i>string</i>').should == '<i>string</i>'
    end
    it "should leave quotes alone" do
      @formatter.make_html_safe('"string"').should == '"string"'
    end
    it "should return an html_safe string" do
      @formatter.make_html_safe('"string"').should be_html_safe
    end
    it "should escape other HTML" do
      @formatter.make_html_safe('<script>danger</script>').should == '&lt;script&gt;danger&lt;/script&gt;'
    end
  end

  describe "formatting reference" do
    it "should format the reference" do
      reference = FactoryGirl.create(:article_reference, :author_names => [@author_name],
                          :citation_year => "1874",
                          :title => "Les fourmis de la Suisse",
                          :journal => @journal, :series_volume_issue => "26", :pagination => "1-452")
      string = @formatter.format reference
      string.should be_html_safe
      string.should == 'Forel, A. 1874. Les fourmis de la Suisse. Neue Denkschriften 26:1-452.'
    end

    it "should add a period after the title if none exists" do
      reference = FactoryGirl.create(:article_reference, :author_names => [@author_name],
                          :citation_year => "1874",
                          :title => "Les fourmis de la Suisse",
                          :journal => @journal, :series_volume_issue => "26", :pagination => "1-452")
      @formatter.format(reference).should == 'Forel, A. 1874. Les fourmis de la Suisse. Neue Denkschriften 26:1-452.'
    end

    it "should not add a period after the author_names' suffix" do
      reference = FactoryGirl.create(:article_reference, :author_names => [@author_name],
                          :citation_year => "1874",
                          :title => "Les fourmis de la Suisse",
                          :journal => @journal, :series_volume_issue => "26", :pagination => "1-452")
      reference.update_attribute :author_names_suffix, ' (ed.)'
      @formatter.format(reference).should == 'Forel, A. (ed.) 1874. Les fourmis de la Suisse. Neue Denkschriften 26:1-452.'
    end

    it "should not add a period after the title if it ends with a question mark" do
      reference = FactoryGirl.create(:article_reference, :author_names => [@author_name],
                          :citation_year => "1874",
                          :title => "Les fourmis de la Suisse?",
                          :journal => @journal, :series_volume_issue => "26", :pagination => "1-452")
      @formatter.format(reference).should == 'Forel, A. 1874. Les fourmis de la Suisse? Neue Denkschriften 26:1-452.'
    end

    it "should not add a period after the title if it ends with an exclamation mark" do
      reference = FactoryGirl.create(:article_reference, :author_names => [@author_name],
                          :citation_year => "1874",
                          :title => "Les fourmis de la Suisse!",
                          :journal => @journal, :series_volume_issue => "26", :pagination => "1-452")
      @formatter.format(reference).should == 'Forel, A. 1874. Les fourmis de la Suisse! Neue Denkschriften 26:1-452.'
    end

    it "should not add a period after the title if there's already one" do
      reference = FactoryGirl.create(:article_reference, :author_names => [@author_name],
                          :citation_year => "1874",
                          :title => "Les fourmis de la Suisse.",
                          :journal => @journal, :series_volume_issue => "26", :pagination => "1-452")
      @formatter.format(reference).should == 'Forel, A. 1874. Les fourmis de la Suisse. Neue Denkschriften 26:1-452.'
    end

    it "should add a period after the citation if none exists" do
      reference = FactoryGirl.create(:article_reference, :author_names => [@author_name],
                          :citation_year => "1874",
                          :title => "Les fourmis de la Suisse.",
                          :journal => @journal, :series_volume_issue => "26", :pagination => "1-452")
      @formatter.format(reference).should == 'Forel, A. 1874. Les fourmis de la Suisse. Neue Denkschriften 26:1-452.'
    end

    it "should not add a period after the citation if there's already one" do
      reference = FactoryGirl.create(:article_reference, :author_names => [@author_name],
                          :citation_year => "1874",
                          :title => "Les fourmis de la Suisse.",
                          :journal => @journal, :series_volume_issue => "26", :pagination => "1-452.")
      @formatter.format(reference).should == 'Forel, A. 1874. Les fourmis de la Suisse. Neue Denkschriften 26:1-452.'
    end

    it "should separate the publisher and the pagination with a comma" do
      reference = FactoryGirl.create(:book_reference, :author_names => [@author_name],
                          :citation_year => "1874",
                          :title => "Les fourmis de la Suisse.",
                          :publisher => @publisher, :pagination => "22 pp.")
      @formatter.format(reference).should == 'Forel, A. 1874. Les fourmis de la Suisse. New York: Wiley, 22 pp.'
    end

    it "should format an unknown reference" do
      reference = FactoryGirl.create(:unknown_reference, :author_names => [@author_name],
                          :citation_year => "1874",
                          :title => "Les fourmis de la Suisse.", :citation => 'New York')
      @formatter.format(reference).should == 'Forel, A. 1874. Les fourmis de la Suisse. New York.'
    end

    it "should format a nested reference" do
      reference = FactoryGirl.create :book_reference,
        :author_names => [FactoryGirl.create(:author_name, :name => 'Mayr, E.')],
        :citation_year => '2010',
        :title => 'Ants I have known',
        :publisher => FactoryGirl.create(:publisher, :name => 'Wiley', :place => FactoryGirl.create(:place, :name => 'New York')),
        :pagination => '32 pp.'
      nested_reference = FactoryGirl.create :nested_reference, :nested_reference => reference,
        :author_names => [@author_name], :title => 'Les fourmis de la Suisse',
        :citation_year => '1874', :pages_in => 'Pp. 32-45 in'
      @formatter.format(nested_reference).should ==
        'Forel, A. 1874. Les fourmis de la Suisse. Pp. 32-45 in Mayr, E. 2010. Ants I have known. New York: Wiley, 32 pp.'
    end

    it "should format a citation_string correctly if the publisher doesn't have a place" do
      publisher = Publisher.create! :name => "Wiley"
      reference = FactoryGirl.create(:book_reference,
                          :author_names => [@author_name],
                          :citation_year => "1874",
                          :title => "Les fourmis de la Suisse.",
                          :publisher => publisher, :pagination => "22 pp.")
      @formatter.format(reference).should == 'Forel, A. 1874. Les fourmis de la Suisse. Wiley, 22 pp.'
    end

    describe "unsafe characters" do
      before do
        @author_names = [FactoryGirl.create(:author_name, :name => 'Ward, P. S.')]
        @reference = FactoryGirl.create :unknown_reference, :author_names => @author_names,
          :citation_year => "1874", :title => "Les fourmis de la Suisse.", :citation => '32 pp.'
      end
      it "should escape everything, but let italics through" do
        @reference.author_names = [FactoryGirl.create(:author_name, :name => '<script>')]
        @formatter.format(@reference).should == '&lt;script&gt; 1874. Les fourmis de la Suisse. 32 pp.'
      end
      it "should escape the citation year" do
        @reference.update_attribute :citation_year, '<script>'
        @formatter.format(@reference).should == 'Ward, P. S. &lt;script&gt;. Les fourmis de la Suisse. 32 pp.'
      end
      it "should escape the title" do
        @reference.update_attribute :title, '<script>'
        @formatter.format(@reference).should == 'Ward, P. S. 1874. &lt;script&gt;. 32 pp.'
      end
      it "should escape the title but leave the italics alone" do
        @reference.update_attribute :title, '*foo*<script>'
        @formatter.format(@reference).should == 'Ward, P. S. 1874. <i>foo</i>&lt;script&gt;. 32 pp.'
      end
      it "should escape the date" do
        @reference.update_attribute :date, '1933>'
        @formatter.format(@reference).should == 'Ward, P. S. 1874. Les fourmis de la Suisse. 32 pp. [1933&gt;]'
      end

      it "should escape the citation in an article reference" do
        reference = FactoryGirl.create :article_reference, :title => 'Ants are my life', :author_names => @author_names,
          :journal => FactoryGirl.create(:journal, :name => '<script>'), :citation_year => '2010d', :series_volume_issue => '<', :pagination => '>'
        @formatter.format(reference).should == 'Ward, P. S. 2010d. Ants are my life. &lt;script&gt; &lt;:&gt;.'
      end

      it "should escape the citation in a book reference" do
        reference = FactoryGirl.create :book_reference, :citation_year => '2010d', :title => 'Ants are my life', :author_names => @author_names,
          :publisher => FactoryGirl.create(:publisher, :name => '<', :place => FactoryGirl.create(:place, :name => '>')), :pagination => '>'
        @formatter.format(reference).should == 'Ward, P. S. 2010d. Ants are my life. &gt;: &lt;, &gt;.'
      end

      it "should escape the citation in an unknown reference" do
        reference = FactoryGirl.create :unknown_reference, :title => 'Ants are my life', :citation_year => '2010d', :author_names => @author_names, :citation => '>'
        @formatter.format(reference).should == 'Ward, P. S. 2010d. Ants are my life. &gt;.'
      end

      it "should escape the citation in a nested reference" do
        nested_reference = FactoryGirl.create :unknown_reference, :title => "Ants are my life", :citation_year => '2010d', :author_names => @author_names
        reference = FactoryGirl.create :nested_reference, :title => "Ants are my life", :citation_year => '2010d', :author_names => @author_names, :pages_in => '>', :nested_reference => nested_reference
        @formatter.format(reference).should == 'Ward, P. S. 2010d. Ants are my life. &gt; Ward, P. S. 2010d. Ants are my life. New York.'
      end

    end

    describe "Italicizing title and citation" do
      it "should return an html_safe string" do
        reference = FactoryGirl.create :unknown_reference, :citation_year => '2010d', :author_names => [], :citation => '*Ants*', :title => '*Tapinoma*'
        @formatter.format(reference).should be_html_safe
      end
      it "should italicize the title and citation" do
        reference = FactoryGirl.create :unknown_reference, :citation_year => '2010d', :author_names => [], :citation => '*Ants*', :title => '*Tapinoma*'
        @formatter.format(reference).should == "2010d. <i>Tapinoma</i>. <i>Ants</i>."
      end
      it "should italicize the title even with two italicized words" do
        reference = FactoryGirl.create :unknown_reference, :citation_year => '2010d',
          :author_names => [], :citation => 'Ants', :title => 'Note on a new northern cutting ant, *Atta* *septentrionalis*.'
        @formatter.format(reference).should == "2010d. Note on a new northern cutting ant, <i>Atta</i> <i>septentrionalis</i>. Ants."
      end
      it "should allow existing italics in title and citation" do
        reference = FactoryGirl.create :unknown_reference, :citation_year => '2010d', :author_names => [], :citation => '*Ants*', :title => '<i>Tapinoma</i>'
        @formatter.format(reference).should == "2010d. <i>Tapinoma</i>. <i>Ants</i>."
      end
      it "should escape other HTML in title and citation" do
        reference = FactoryGirl.create :unknown_reference, :citation_year => '2010d', :author_names => [], :citation => '*Ants*', :title => '<span>Tapinoma</span>'
        @formatter.format(reference).should == "2010d. &lt;span&gt;Tapinoma&lt;/span&gt;. <i>Ants</i>."
      end
      it "should not escape et al. in citation" do
        reference = FactoryGirl.create :unknown_reference, author_names: [], citation_year: '2010', citation: 'Ants <i>et al.</i>', title: 'Tapinoma'
        @formatter.format(reference).should == "2010. Tapinoma. Ants <i>et al.</i>."
      end
      it "should not escape et al. in citation for a missing reference" do
        reference = FactoryGirl.create :missing_reference, author_names: [], citation_year: '2010', citation: 'Ants <i>et al.</i>', title: 'Tapinoma'
        @formatter.format(reference).should == "2010. Tapinoma. Ants <i>et al.</i>"
      end
    end

    describe "Escaping in the year" do
      it "should leave quotes (and italics) alone, but escape other HTML" do
        reference = FactoryGirl.create :unknown_reference, citation_year: '2010 ("2011")', author_names: [], citation: 'Ants', title: 'Tapinoma'
        string = Formatters::ReferenceFormatter.make_formatter(reference).format_year
        string.should == '2010 ("2011")'
        string.should be_html_safe
      end
    end

    describe "Escaping in the author names" do
      it "should not escape quotes and italics, should escape everything else" do
        reference = FactoryGirl.create :unknown_reference, author_names: [@author_name], citation: 'Ants', title: 'Tapinoma', author_names_suffix: ' <i>et al.</i>'
        string = Formatters::ReferenceFormatter.make_formatter(reference).format_author_names
        string.should == 'Forel, A. <i>et al.</i>'
        string.should be_html_safe
      end
    end

  end

  it "should not have a space at the beginning when there are no authors" do
    reference = FactoryGirl.create :unknown_reference, :citation_year => '2010d', :author_names => [], :citation => 'Ants', :title => 'Tapinoma'
    @formatter.format(reference).should == "2010d. Tapinoma. Ants."
  end


  describe "formatting the date" do
    it "should use ISO 8601 format for calendar dates" do
      make '20101213'; check ' [2010-12-13]'
    end
    it "should handle years without months and days" do
      make '201012'; check ' [2010-12]'
    end
    it "should handle years with months but without days" do
      make '2010'; check ' [2010]'
    end
    it "should handle missing date" do
      make nil; check ''
    end
    it "should handle missing date" do
      make ''; check ''
    end
    it "should handle dates with other symbols/characters" do
      make '201012>'; check ' [2010-12&gt;]'
    end

    def make date
      @reference = FactoryGirl.create(:article_reference, :author_names => [@author_name],
                           :citation_year => "1874",
                           :title => "Les fourmis de la Suisse.",
                           :journal => @journal, :series_volume_issue => "26", :pagination => "1-452.", :date => date)
    end

    def check expected
      @formatter.format(@reference).should == "Forel, A. 1874. Les fourmis de la Suisse. Neue Denkschriften 26:1-452.#{expected}"
    end
  end

  describe "italicizing" do
    it "should replace asterisks and bars with italics" do
      string = @formatter.format_italics "|Hymenoptera| *Formicidae*".html_safe
      string.should == "<i>Hymenoptera</i> <i>Formicidae</i>"
      string.should be_html_safe
    end
    it "should raise if the string isn't html_safe already" do
      -> {@formatter.format_italics 'roman'}.should raise_error
    end
  end

  describe "inline_citation" do
    describe "with links" do
      it "nonmissing references should defer to the key" do
        key = double
        reference = FactoryGirl.create :article_reference
        reference.should_receive(:key).and_return key
        key.should_receive(:to_link)

        @formatter.format_inline_citation reference
      end
      it "should just output the citation for a MissingReference" do
        @formatter.format_inline_citation(FactoryGirl.create(:missing_reference, :citation => 'foo')).should == 'foo'
      end
    end
    describe "without links" do
      it "nonmissing references should defer to the key" do
        key = double
        reference = FactoryGirl.create :article_reference
        reference.should_receive(:key).and_return key
        key.should_receive(:to_s)

        @formatter.format_inline_citation_without_links reference
      end
    end
  end

  describe "formatting a timestamp" do
    it "should use a short format" do
      @formatter.format_timestamp(Time.parse('2001-1-2')).should == '2001-01-02'
    end
  end

  describe "Formatting review status" do
    it "should return the display string for a review status" do
      @formatter.format_review_state('reviewed').should == 'Reviewed'
      @formatter.format_review_state('reviewing').should == 'Being reviewed'
      @formatter.format_review_state('none').should == ''
      @formatter.format_review_state('').should == ''
      @formatter.format_review_state(nil).should == ''
    end
  end

  describe "A regression where a string should've been duped" do
    it "really should have been duped" do
      journal = FactoryGirl.create :journal, name: 'Ants'
      author_name = @author_name
      reference = FactoryGirl.create :article_reference,
        author_names: [author_name], citation_year: '1874', title: 'Format',
        journal: journal, series_volume_issue: '1:1', pagination: '2'
      expected = 'Forel, A. 1874. Format. Ants 1:1:2.'
      @formatter.format(reference).should == expected
    end
  end

  describe "Formatting reference into HTML, with rollover" do
    it "should work" do
      journal = FactoryGirl.create :journal, name: 'Ants'
      author_name = @author_name
      reference = FactoryGirl.create :article_reference,
        author_names: [author_name], citation_year: '1874', title: 'Format',
        journal: journal, series_volume_issue: '1:1', pagination: '2'
      expected = '<span title="Forel, A. 1874. Format. Ants 1:1:2.">Forel, 1874</span>'
      @formatter.format_authorship_html(reference).should === expected
    end
  end

end
