# coding: UTF-8
require 'spec_helper'

describe Reference do
  include EnableSunspot

  describe "Searching (do_do_search)" do

    describe "Search parameters" do

      describe "Searching for nothing" do
        it "should return everything" do
          reference = Factory :reference
          Reference.do_do_search.should == [reference]
        end
      end

      describe "Searching for authors" do
        it "should return an empty array if nothing is found for the author names" do
          Reference.do_do_search(:authors => [Factory(:author)]).should be_empty
        end
        it "should find the reference for a given author_name if it exists" do
          bolton = Factory :author_name
          reference = Factory :book_reference, :author_names => [bolton]
          Factory :book_reference, :author_names => [Factory(:author_name, :name => 'Fisher')]
          results = Reference.do_do_search(:authors => [bolton.author])
          results.should == [reference]
        end
        it "should find the references for all aliases of a given author_name" do
          bolton = Factory :author
          bolton_barry = Factory :author_name, :author => bolton, :name => 'Bolton, Barry'
          bolton_b = Factory :author_name, :author => bolton, :name => 'Bolton, B.'
          bolton_barry_reference = Factory :book_reference, :author_names => [bolton_barry], :title => '1', :pagination => '1'
          bolton_b_reference = Factory :book_reference, :author_names => [bolton_b], :title => '2', :pagination => '2'
          Reference.do_do_search(:authors => [bolton]).map(&:id).should =~
            [bolton_b_reference, bolton_barry_reference].map(&:id)
        end
        it "should find the reference with both author names, but not just one" do
          bolton = Factory :author_name, :name => 'Bolton'
          fisher = Factory :author_name, :name => 'Fisher'
          bolton_reference = Factory :reference, :author_names => [bolton]
          fisher_reference = Factory :reference, :author_names => [fisher]
          bolton_fisher_reference = Factory :reference, :author_names => [bolton,fisher]
          Reference.do_do_search(:authors => [bolton.author, fisher.author]).should == [bolton_fisher_reference]
        end
      end

    end

    describe "Sorting" do
      it "should be able to sort by updated_at" do
        Reference.record_timestamps = false
        updated_yesterday = reference_factory(:author_name => 'Fisher', :citation_year => '1910b')
        updated_yesterday.update_attribute(:updated_at,  Time.now.yesterday)
        updated_last_week = reference_factory(:author_name => 'Wheeler', :citation_year => '1874')
        updated_last_week.update_attribute(:updated_at,  1.week.ago)
        updated_today = reference_factory(:author_name => 'Fisher', :citation_year => '1910a')
        updated_today.update_attribute(:updated_at,  Time.now)
        Reference.record_timestamps = true

        Reference.do_do_search(:order => :updated_at).should == [updated_today, updated_yesterday, updated_last_week]
      end
    end

  end


  #describe "Searching" do

    #it "should handle the current year + the next year" do
      #bolton = reference_factory(:author_name => 'Bolton', :citation_year => Time.now.year.to_s)
      #bolton
      #fisher = reference_factory(:author_name => 'Fisher', :citation_year => (Time.now.year + 1).to_s)
      #fisher
      #Reference.do_search(:q => "Bolton #{Time.now.year}").should == [bolton]
      #Reference.do_search(:q => "Fisher #{Time.now.year + 1}").should == [fisher]
    #end

    #it "should not strip the year from the string" do
      #string = '1990'
      #Reference.do_search :q => string
      #string.should == '1990'
    #end

    #describe 'searching by author_name' do
      #it 'should at least find Bert!' do
        #reference = reference_factory(:author_name => 'Hölldobler')
        #Reference.do_search(:q => 'holldobler').should == [reference]
      #end
      #it 'should at least find Bert, even when the diacritic is used in the search term' do
        #reference = reference_factory(:author_name => 'Hölldobler')
        #Reference.do_search(:q => 'Hölldobler').should == [reference]
      #end
    #end

    #describe 'searching by cite code' do
      #it "should find a cite code that's doesn't look like a current year" do
        #matching_reference = reference_factory(:author_name => 'Hölldobler', :cite_code => 'abcdef')
        #unmatching_reference = reference_factory(:author_name => 'Hölldobler', :cite_code => 'fedcba')
        #Reference.do_search(:q => 'abcdef').should == [matching_reference]
      #end

      #it "should find a cite code that looks like a year, but not a current year" do
        #matching_reference = reference_factory(:author_name => 'Hölldobler', :cite_code => '1600')
        #Reference.do_search(:q => '1600').should == [matching_reference]
      #end
    #end

    #describe 'searching notes' do
      ##it 'should find something in public notes' do
        ##matching_reference = reference_factory(:author_name => 'Hölldobler', :public_notes => 'abcdef')
        ##unmatching_reference = reference_factory(:author_name => 'Hölldobler', :public_notes => 'fedcba')
        ##Reference.do_search(:q => 'abcdef').should == [matching_reference]
      ##end
      #it 'should find something in editor notes' do
        #matching_reference = reference_factory(:author_name => 'Hölldobler', :editor_notes => 'abcdef')
        #unmatching_reference = reference_factory(:author_name => 'Hölldobler', :editor_notes => 'fedcba')
        #Reference.do_search(:q => 'abcdef').should == [matching_reference]
      #end
      #it 'should find something in taxonomic notes' do
        #matching_reference = reference_factory(:author_name => 'Hölldobler', :taxonomic_notes => 'abcdef')
        #unmatching_reference = reference_factory(:author_name => 'Hölldobler', :taxonomic_notes => 'fedcba')
        #Reference.do_search(:q => 'abcdef').should == [matching_reference]
      #end
    #end

    #describe 'searching journal name' do
      #it 'should find something in journal name' do
        #journal = Factory :journal, :name => 'Journal'
        #matching_reference = reference_factory(:author_name => 'Hölldobler', :journal => journal)
        #unmatching_reference = reference_factory(:author_name => 'Hölldobler')
        #Reference.do_search(:q => 'journal').should == [matching_reference]
      #end
    #end

    #describe 'searching publisher name' do
      #it 'should find something in publisher name' do
        #publisher = Factory :publisher, :name => 'Publisher'
        #matching_reference = reference_factory(:author_name => 'Hölldobler', :publisher => publisher)
        #unmatching_reference = reference_factory(:author_name => 'Hölldobler')
        #Reference.do_search(:q => 'Publisher').should == [matching_reference]
      #end
    #end

    #describe 'searching citation (for Unknown references)' do
      #it 'should find something in citation' do
        #matching_reference = reference_factory(:author_name => 'Hölldobler', :citation => 'Citation')
        #unmatching_reference = reference_factory(:author_name => 'Hölldobler')
        #Reference.do_search(:q => 'Citation').should == [matching_reference]
      #end
    #end

    #describe 'searching by year' do
      #before do
        #reference_factory(:author_name => 'Bolton', :citation_year => '1994')
        #reference_factory(:author_name => 'Bolton', :citation_year => '1995')
        #reference_factory(:author_name => 'Bolton', :citation_year => '1996')
        #reference_factory(:author_name => 'Bolton', :citation_year => '1997')
        #reference_factory(:author_name => 'Bolton', :citation_year => '1998')
      #end

      #it "should return an empty array if nothing is found for year" do
        #Reference.do_search(:q => '1992-1993').should be_empty
      #end

      #it "should find entries in between the start year and the end year (inclusive)" do
        #Reference.do_search(:q => '1995-1996').map(&:year).should =~ [1995, 1996]
      #end

      #it "should find references in the year of the end range, even if they have extra characters" do
        #reference_factory(:author_name => 'Bolton', :citation_year => '2004.')
        #Reference.do_search(:q => '2004').map(&:year).should =~ [2004]
      #end
    #end

    #describe "Filtering unknown reference types" do
      #it "should just return unknown reference types if a ? is passed as the search term" do
        #known = Factory :article_reference
        #unknown = Factory :unknown_reference
        #Reference.do_search(:q => '?').should == [unknown]
      #end
    #end

    #describe "sorting search results" do
      #it "should sort by author_name plus year plus letter" do
        #fisher1910b = reference_factory(:author_name => 'Fisher', :citation_year => '1910b')
        #wheeler1874 = reference_factory(:author_name => 'Wheeler', :citation_year => '1874')
        #fisher1910a = reference_factory(:author_name => 'Fisher', :citation_year => '1910a')
        #Reference.do_search.should == [fisher1910a, fisher1910b, wheeler1874]
      #end

      #it "should sort by multiple author_names using their order in each reference" do
        #a = Factory(:article_reference, :author_names => AuthorName.import_author_names_string('Abdalla, F. C.; Cruz-Landim, C. da.')[:author_names])
        #m = Factory(:article_reference, :author_names => AuthorName.import_author_names_string('Mueller, U. G.; Mikheyev, A. S.; Abbot, P.')[:author_names])
        #v = Factory(:article_reference, :author_names => AuthorName.import_author_names_string("Vinson, S. B.; MacKay, W. P.; Rebeles M.; A.; Arredondo B.; H. C.; Rodríguez R.; A. D.; González, D. A.")[:author_names])
        #Reference.do_search.should == [a, m, v]
      #end

      #it "should sort by multiple author_names using their order in each reference" do
        #a = Factory(:article_reference, :author_names => AuthorName.import_author_names_string('Abdalla, F. C.; Cruz-Landim, C. da.')[:author_names]) 
        #m = Factory(:article_reference, :author_names => AuthorName.import_author_names_string('Mueller, U. G.; Mikheyev, A. S.; Abbot, P.')[:author_names])
        #v = Factory(:article_reference, :author_names => AuthorName.import_author_names_string("Vinson, S. B.; MacKay, W. P.; Rebeles M.; A.; Arredondo B.; H. C.; Rodríguez R.; A. D.; González, D. A.")[:author_names])
        #Reference.do_search.should == [a, m, v]
      #end

    #end

    #describe "new" do
      #it "should sort by created_at" do

        #Reference.record_timestamps = false
        #created_yesterday = reference_factory(:author_name => 'Fisher', :citation_year => '1910b')
        #created_yesterday.update_attribute(:created_at,  Time.now.yesterday)
        #created_last_week = reference_factory(:author_name => 'Wheeler', :citation_year => '1874')
        #created_last_week.update_attribute(:created_at,  1.week.ago)
        #created_today = reference_factory(:author_name => 'Fisher', :citation_year => '1910a')
        #created_today.update_attribute(:created_at,  Time.now)
        #Reference.record_timestamps = true

        #Reference.do_search(:whats_new => true).should == [created_today, created_yesterday, created_last_week]
      #end
    #end

    #describe "searching by ID" do
      #it "should ignore everything else if an ID of sufficient length is provided" do
        #reference = Factory :reference
        #sql = "UPDATE `references` SET id = 12345 WHERE id = #{reference.id}"
        #ActiveRecord::Base.connection.execute sql
        #Factory :reference
        #Reference.do_search(:q => '12345 1972 Bolton').should == [Reference.find(12345)]
      #end
      #it "should not freak out if it can't find the ID" do
        #reference = Factory :reference
        #Factory :reference
        #Reference.do_search(:q => '12345').should == []
      #end
    #end

  #end

  # this tests that Reference extracts the parameters correctly for do_do_search
  describe "Do search" do

    describe "Searching for nothing" do
      it "should return everything" do
        Reference.should_receive(:do_do_search).with()
        Reference.do_search
      end
    end

    describe "Review" do
      it "should sort by updated_at" do
        Reference.should_receive(:do_do_search).with(:order => :updated_at, :page => nil)
        Reference.do_search :review => true
      end
    end

    describe "Searching for author(s)" do
      it "send along the authors for the author names" do
        bolton = Factory :author_name, :name => 'Bolton'
        fisher = Factory :author_name, :name => 'Bolton'
        bolton_b = Factory :author_name, :name => 'Bolton, B.', :author => bolton.author

        Factory :book_reference, :author_names => [bolton], :citation_year => '2001'
        Factory :book_reference, :author_names => [bolton_b], :citation_year => '2005'
        Factory :book_reference, :author_names => [fisher], :citation_year => '2003'

        Reference.should_receive(:do_do_search) do |options|
          options[:authors].size.should == 2
          options[:authors].first.should == bolton.author
          options[:authors].second.should == fisher.author
        end

        Reference.do_search :authors => 'Bolton; Fisher', :page => nil
      end
    end

  end

  describe "Searching with Solr" do
    it "should return an empty array if nothing is found for author_name" do
      Factory :reference
      Reference.search {keywords 'foo'}.results.should be_empty
    end

    it "should find the reference for a given author_name if it exists" do
      reference = reference_factory(:author_name => 'Bolton')
      reference_factory(:author_name => 'Fisher')
      Reference.search {keywords 'Bolton'}.results.should == [reference]
    end

    it "should return an empty array if nothing is found for a given year and author_name" do
      reference_factory(:author_name => 'Bolton', :citation_year => '2010')
      reference_factory(:author_name => 'Bolton', :citation_year => '1995')
      reference_factory(:author_name => 'Fisher', :citation_year => '2011')
      reference_factory(:author_name => 'Fisher', :citation_year => '1996')
      Reference.search {
        with(:year).between(2012..2013)
        keywords 'Fisher'
      }.results.should be_empty
    end

    it "should return the one reference for a given year and author_name" do
      reference_factory(:author_name => 'Bolton', :citation_year => '2010')
      reference_factory(:author_name => 'Bolton', :citation_year => '1995')
      reference_factory(:author_name => 'Fisher', :citation_year => '2011')
      reference = reference_factory(:author_name => 'Fisher', :citation_year => '1996')
      Reference.search {
        with(:year).between(1996..1996)
        keywords 'Fisher'
      }.results.should == [reference]
    end

  end

end
