require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ReferenceHelper do
  before do
    @journal = Factory :journal, :name => "Neue Denkschriften"
    @author = Factory :author, :name => "Forel, A."
    @publisher = Factory :publisher
  end

  describe "formattng reference" do
    it "should format the reference" do
      reference = Factory(:article_reference, :authors => [@author], :citation_year => "1874", :title => "Les fourmis de la Suisse",
                          :journal => @journal, :series_volume_issue => "26", :pagination => "1-452")
      helper.format_reference(reference).should == 'Forel, A. 1874. Les fourmis de la Suisse. Neue Denkschriften 26:1-452.'
    end

    it "should add a period after the title if none exists" do
      reference = Factory(:article_reference, :authors => [@author], :citation_year => "1874", :title => "Les fourmis de la Suisse",
                          :journal => @journal, :series_volume_issue => "26", :pagination => "1-452")
      helper.format_reference(reference).should == 'Forel, A. 1874. Les fourmis de la Suisse. Neue Denkschriften 26:1-452.'
    end

    it "should not add a period after the authors' suffix" do
      reference = Factory(:article_reference, :authors => [@author], :citation_year => "1874", :title => "Les fourmis de la Suisse",
                          :journal => @journal, :series_volume_issue => "26", :pagination => "1-452")
      reference.update_attribute :authors_suffix, ' (ed.)'
      helper.format_reference(reference).should == 'Forel, A. (ed.) 1874. Les fourmis de la Suisse. Neue Denkschriften 26:1-452.'
    end

    it "should not add a period after the title if there's already one" do
      reference = Factory(:article_reference, :authors => [@author], :citation_year => "1874", :title => "Les fourmis de la Suisse.",
                          :journal => @journal, :series_volume_issue => "26", :pagination => "1-452")
      helper.format_reference(reference).should == 'Forel, A. 1874. Les fourmis de la Suisse. Neue Denkschriften 26:1-452.'
    end

    it "should add a period after the citation if none exists" do
      reference = Factory(:article_reference, :authors => [@author], :citation_year => "1874", :title => "Les fourmis de la Suisse.",
                          :journal => @journal, :series_volume_issue => "26", :pagination => "1-452")
      helper.format_reference(reference).should == 'Forel, A. 1874. Les fourmis de la Suisse. Neue Denkschriften 26:1-452.'
    end

    it "should not add a period after the citation if there's already one" do
      reference = Factory(:article_reference, :authors => [@author], :citation_year => "1874", :title => "Les fourmis de la Suisse.",
                          :journal => @journal, :series_volume_issue => "26", :pagination => "1-452.")
      helper.format_reference(reference).should == 'Forel, A. 1874. Les fourmis de la Suisse. Neue Denkschriften 26:1-452.'
    end

    it "should separate the publisher and the pagination with a comma" do
      reference = Factory(:book_reference, :authors => [@author], :citation_year => "1874", :title => "Les fourmis de la Suisse.",
                          :publisher => @publisher, :pagination => "22 pp.")
      helper.format_reference(reference).should == 'Forel, A. 1874. Les fourmis de la Suisse. New York: Wiley, 22 pp.'
    end

    it "should format an unknown reference" do
      reference = Factory(:unknown_reference, :authors => [@author], :citation_year => "1874", :title => "Les fourmis de la Suisse.",
                          :citation => 'New York')
      helper.format_reference(reference).should == 'Forel, A. 1874. Les fourmis de la Suisse. New York.'
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
      make '201012>'; check ' [2010-12>]'
    end

    def make date
      @reference = Factory(:article_reference, :authors => [@author], :citation_year => "1874", :title => "Les fourmis de la Suisse.",
                           :journal => @journal, :series_volume_issue => "26", :pagination => "1-452.", :date => date)
    end

    def check expected
      helper.format_reference(@reference).should == "Forel, A. 1874. Les fourmis de la Suisse. Neue Denkschriften 26:1-452.#{expected}"
    end
  end

  describe "italicizing" do
    it "should replace asterisks and bars with spans of a certain class" do
      helper.italicize("|Hymenoptera| *Formicidae*").should == "<span class=taxon>Hymenoptera</span> <span class=taxon>Formicidae</span>"
    end
  end
end
