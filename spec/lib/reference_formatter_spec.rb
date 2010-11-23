require 'spec_helper'

describe ReferenceFormatter do
  before do
    @journal = Factory :journal, :name => "Neue Denkschriften"
    @author_name = Factory :author_name, :name => "Forel, A."
    @publisher = Factory :publisher
  end

  describe "formatting reference" do
    it "should format the reference" do
      reference = Factory(:article_reference, :author_names => [@author_name],
                          :citation_year => "1874",
                          :title => "Les fourmis de la Suisse",
                          :journal => @journal, :series_volume_issue => "26", :pagination => "1-452")
      ReferenceFormatter.format(reference).should == 'Forel, A. 1874. Les fourmis de la Suisse. Neue Denkschriften 26:1-452.'
    end

    it "should add a period after the title if none exists" do
      reference = Factory(:article_reference, :author_names => [@author_name],
                          :citation_year => "1874",
                          :title => "Les fourmis de la Suisse",
                          :journal => @journal, :series_volume_issue => "26", :pagination => "1-452")
      ReferenceFormatter.format(reference).should == 'Forel, A. 1874. Les fourmis de la Suisse. Neue Denkschriften 26:1-452.'
    end

    it "should not add a period after the author_names' suffix" do
      reference = Factory(:article_reference, :author_names => [@author_name],
                          :citation_year => "1874",
                          :title => "Les fourmis de la Suisse",
                          :journal => @journal, :series_volume_issue => "26", :pagination => "1-452")
      reference.update_attribute :author_names_suffix, ' (ed.)'
      ReferenceFormatter.format(reference).should == 'Forel, A. (ed.) 1874. Les fourmis de la Suisse. Neue Denkschriften 26:1-452.'
    end

    it "should not add a period after the title if there's already one" do
      reference = Factory(:article_reference, :author_names => [@author_name],
                          :citation_year => "1874",
                          :title => "Les fourmis de la Suisse.",
                          :journal => @journal, :series_volume_issue => "26", :pagination => "1-452")
      ReferenceFormatter.format(reference).should == 'Forel, A. 1874. Les fourmis de la Suisse. Neue Denkschriften 26:1-452.'
    end

    it "should add a period after the citation if none exists" do
      reference = Factory(:article_reference, :author_names => [@author_name],
                          :citation_year => "1874",
                          :title => "Les fourmis de la Suisse.",
                          :journal => @journal, :series_volume_issue => "26", :pagination => "1-452")
      ReferenceFormatter.format(reference).should == 'Forel, A. 1874. Les fourmis de la Suisse. Neue Denkschriften 26:1-452.'
    end

    it "should not add a period after the citation if there's already one" do
      reference = Factory(:article_reference, :author_names => [@author_name],
                          :citation_year => "1874",
                          :title => "Les fourmis de la Suisse.",
                          :journal => @journal, :series_volume_issue => "26", :pagination => "1-452.")
      ReferenceFormatter.format(reference).should == 'Forel, A. 1874. Les fourmis de la Suisse. Neue Denkschriften 26:1-452.'
    end

    it "should separate the publisher and the pagination with a comma" do
      reference = Factory(:book_reference, :author_names => [@author_name],
                          :citation_year => "1874",
                          :title => "Les fourmis de la Suisse.",
                          :publisher => @publisher, :pagination => "22 pp.")
      ReferenceFormatter.format(reference).should == 'Forel, A. 1874. Les fourmis de la Suisse. New York: Wiley, 22 pp.'
    end

    it "should format an unknown reference" do
      reference = Factory(:unknown_reference, :author_names => [@author_name],
                          :citation_year => "1874",
                          :title => "Les fourmis de la Suisse.", :citation => 'New York')
      ReferenceFormatter.format(reference).should == 'Forel, A. 1874. Les fourmis de la Suisse. New York.'
    end

    it "should format a nested reference" do
      reference = Factory :book_reference,
        :author_names => [Factory :author_name, :name => 'Mayr, E.'],
        :citation_year => '2010',
        :title => 'Ants I have known',
        :publisher => Factory(:publisher, :name => 'Wiley', :place => Factory(:place, :name => 'New York')),
        :pagination => '32 pp.'
      nested_reference = Factory :nested_reference, :nested_reference => reference,
        :author_names => [Factory :author_name, :name => 'Forel, A.'], :title => 'Les fourmis de la Suisse',
        :citation_year => '1874', :pages_in => 'Pp. 32-45 in'
      ReferenceFormatter.format(nested_reference).should ==
        'Forel, A. 1874. Les fourmis de la Suisse. Pp. 32-45 in Mayr, E. 2010. Ants I have known. New York: Wiley, 32 pp.'
    end

    it "should format a citation_string correctly if the publisher doesn't have a place" do
      publisher = Publisher.create! :name => "Wiley"
      reference = Factory(:book_reference,
                          :author_names => [Factory :author_name, :name => 'Forel, A.'],
                          :citation_year => "1874",
                          :title => "Les fourmis de la Suisse.",
                          :publisher => publisher, :pagination => "22 pp.")
      ReferenceFormatter.format(reference).should == 'Forel, A. 1874. Les fourmis de la Suisse. Wiley, 22 pp.'
    end

    describe "unsafe characters" do
      before do
        @author_names = [Factory :author_name, :name => 'Ward, P. S.']
        @reference = Factory :unknown_reference, :author_names => @author_names,
          :citation_year => "1874", :title => "Les fourmis de la Suisse.", :citation => '32 pp.'
      end
      it "should escape the author_names" do
        @reference.author_names = [Factory(:author_name, :name => '<script>')]
        ReferenceFormatter.format(@reference).should == '&lt;script&gt; 1874. Les fourmis de la Suisse. 32 pp.'
      end
      it "should escape the citation year" do
        @reference.update_attribute :citation_year, '<script>'
        ReferenceFormatter.format(@reference).should == 'Ward, P. S. &lt;script&gt;. Les fourmis de la Suisse. 32 pp.'
      end
      it "should escape the title" do
        @reference.update_attribute :title, '<script>'
        ReferenceFormatter.format(@reference).should == 'Ward, P. S. 1874. &lt;script&gt;. 32 pp.'
      end
      it "should escape the title but leave the italics alone" do
        @reference.update_attribute :title, '*foo*<script>'
        ReferenceFormatter.format(@reference).should == 'Ward, P. S. 1874. <span class=taxon>foo</span>&lt;script&gt;. 32 pp.'
      end
      it "should escape the date" do
        @reference.update_attribute :date, '1933>'
        ReferenceFormatter.format(@reference).should == 'Ward, P. S. 1874. Les fourmis de la Suisse. 32 pp. [1933&gt;]'
      end

      it "should escape the citation in an article reference" do
        reference = Factory :article_reference, :author_names => @author_names,
          :journal => Factory(:journal, :name => '<script>'), :series_volume_issue => '<', :pagination => '>'
        ReferenceFormatter.format(reference).should == 'Ward, P. S. 2010d. Ants are my life. &lt;script&gt; &lt;:&gt;.'
      end

      it "should escape the citation in a book reference" do
        reference = Factory :book_reference, :author_names => @author_names,
          :publisher => Factory(:publisher, :name => '<', :place => Factory(:place, :name => '>')), :pagination => '>'
        ReferenceFormatter.format(reference).should == 'Ward, P. S. 2010d. Ants are my life. &gt;: &lt;, &gt;.'
      end

      it "should escape the citation in an unknown reference" do
        reference = Factory :unknown_reference, :author_names => @author_names, :citation => '>'
        ReferenceFormatter.format(reference).should == 'Ward, P. S. 2010d. Ants are my life. &gt;.'
      end

      it "should escape the citation in a nested reference" do
        nested_reference = Factory :unknown_reference, :author_names => @author_names
        reference = Factory :nested_reference, :author_names => @author_names, :pages_in => '>', :nested_reference => nested_reference
        ReferenceFormatter.format(reference).should == 'Ward, P. S. 2010d. Ants are my life. &gt; Ward, P. S. 2010d. Ants are my life. New York.'
      end

    end

    it "should italicize the title and citation" do
      reference = Factory :unknown_reference, :author_names => [], :citation => '*Ants*', :title => '*Tapinoma*'
      ReferenceFormatter.format(reference).should == "2010d. <span class=taxon>Tapinoma</span>. <span class=taxon>Ants</span>."
    end

    it "should not have a space at the beginning when there are no authors" do
      reference = Factory :unknown_reference, :author_names => [], :citation => 'Ants', :title => 'Tapinoma'
      ReferenceFormatter.format(reference).should == "2010d. Tapinoma. Ants."
    end

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
      make ''; check ''
    end 
    it "should handle dates with other symbols/characters" do
      make '201012>'; check ' [2010-12&gt;]'
    end

    def make date
      @reference = Factory(:article_reference, :author_names => [@author_name],
                           :citation_year => "1874",
                           :title => "Les fourmis de la Suisse.",
                           :journal => @journal, :series_volume_issue => "26", :pagination => "1-452.", :date => date)
    end

    def check expected
      ReferenceFormatter.format(@reference).should == "Forel, A. 1874. Les fourmis de la Suisse. Neue Denkschriften 26:1-452.#{expected}"
    end
  end

  describe "italicizing" do
    it "should replace asterisks and bars with spans of a certain class" do
      ReferenceFormatter.italicize("|Hymenoptera| *Formicidae*").should == "<span class=taxon>Hymenoptera</span> <span class=taxon>Formicidae</span>"
    end
  end

end
