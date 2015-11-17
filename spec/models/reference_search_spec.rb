# coding: UTF-8
require 'spec_helper'

describe Reference, slow: true do

  before do
    Reference.delete_all
    # throw in a MissingReference to make sure it's not returned
    FactoryGirl.create :missing_reference
  end

  describe "Searching (perform_search)" do

    describe "Search parameters" do

      describe "Searching for nothing" do
        it "should return everything" do
          reference = FactoryGirl.create :reference
          expect(Reference.perform_search).to eq([reference])
        end
      end

      describe "Authors" do
        it "should return an empty array if nothing is found for the author names" do
          expect(Reference.perform_search(authors: [FactoryGirl.create(:author)])).to be_empty
        end
        it "should find the reference for a given author_name if it exists" do
          bolton = FactoryGirl.create :author_name
          reference = FactoryGirl.create :book_reference, author_names: [bolton]
          FactoryGirl.create :book_reference, author_names: [FactoryGirl.create(:author_name, name: 'Fisher')]
          results = Reference.perform_search(authors: [bolton.author])
          expect(results).to eq([reference])
        end
        it "should find the references for all aliases of a given author_name" do
          bolton = FactoryGirl.create :author
          bolton_barry = FactoryGirl.create :author_name, author: bolton, name: 'Bolton, Barry'
          bolton_b = FactoryGirl.create :author_name, author: bolton, name: 'Bolton, B.'
          bolton_barry_reference = FactoryGirl.create :book_reference, :author_names => [bolton_barry], :title => '1', :pagination => '1'
          bolton_b_reference = FactoryGirl.create :book_reference, :author_names => [bolton_b], :title => '2', :pagination => '2'
          
          expect(Reference.perform_search(:authors => [bolton]).map(&:id)).to match(
            [bolton_b_reference, bolton_barry_reference].map(&:id)
          )
        end
        it "should find the reference with both author names, but not just one" do
          bolton = FactoryGirl.create :author_name, :name => 'Bolton'
          fisher = FactoryGirl.create :author_name, :name => 'Fisher'
          bolton_reference = FactoryGirl.create :reference, :author_names => [bolton]
          fisher_reference = FactoryGirl.create :reference, :author_names => [fisher]
          bolton_fisher_reference = FactoryGirl.create :reference, :author_names => [bolton,fisher]
          expect(Reference.perform_search(:authors => [bolton.author, fisher.author])).to eq([bolton_fisher_reference])
        end
      end

      describe "ID" do
        it "should ignore everything else if an ID of sufficient length is provided" do
          reference = FactoryGirl.create :reference
          expect(Reference.perform_search(:id => reference.id)).to eq([reference])
        end
        it "should not freak out if it can't find the ID" do
          FactoryGirl.create :reference
          expect(Reference.perform_search(:id => 23)).to eq([])
        end
      end

      describe 'Fulltext', search: true do
        describe 'Notes' do
          it 'should find something in public notes' do
            matching_reference = reference_factory(:author_name => 'Hölldobler', :public_notes => 'abcdef')
            unmatching_reference = reference_factory(:author_name => 'Hölldobler', :public_notes => 'fedcba')
            Sunspot.commit
            expect(Reference.perform_search(:fulltext => 'abcdef')).to eq([matching_reference])
          end
          it 'should find something in editor notes' do
            matching_reference = reference_factory(:author_name => 'Hölldobler', :editor_notes => 'abcdef')
            unmatching_reference = reference_factory(:author_name => 'Hölldobler', :editor_notes => 'fedcba')
            Sunspot.commit
            expect(Reference.perform_search(:fulltext => 'abcdef')).to eq([matching_reference])
          end
          it 'should find something in taxonomic notes' do
            matching_reference = reference_factory(:author_name => 'Hölldobler', :taxonomic_notes => 'abcdef')
            unmatching_reference = reference_factory(:author_name => 'Hölldobler', :taxonomic_notes => 'fedcba')
            Sunspot.commit
            expect(Reference.perform_search(:fulltext => 'abcdef')).to eq([matching_reference])
          end
        end

        describe 'Author names' do
          it 'should at least find Bert!' do
            reference = reference_factory(:author_name => 'Hölldobler')
            # perform_search has no downcase, behaviour changed in rails 4?
            # this used to pass as "perform_search", and it shouldn't have!
            expect(Reference.do_search(:fulltext => 'holldobler')).to eq([reference])
          end
          it 'should at least find Bert, even when the diacritic is used in the search term' do
            reference = reference_factory(:author_name => 'Hölldobler')
            Sunspot.commit
            expect(Reference.perform_search(:fulltext => 'Hölldobler')).to eq([reference])
          end
        end

        describe 'Cite code' do
          it "should find a cite code that's doesn't look like a current year" do
            matching_reference = reference_factory(:author_name => 'Hölldobler', :cite_code => 'abcdef')
            unmatching_reference = reference_factory(:author_name => 'Hölldobler', :cite_code => 'fedcba')
            Sunspot.commit
            expect(Reference.perform_search(:fulltext => 'abcdef')).to eq([matching_reference])
          end
          it "should find a cite code that looks like a year, but not a current year" do
            matching_reference = reference_factory(:author_name => 'Hölldobler', :cite_code => '1600')
            Sunspot.commit
            expect(Reference.perform_search(:fulltext => '1600')).to eq([matching_reference])
          end
        end

        describe 'Journal name' do
          it 'should find something in journal name' do
            journal = FactoryGirl.create :journal, :name => 'Journal'
            matching_reference = reference_factory(:author_name => 'Hölldobler', :journal => journal)
            unmatching_reference = reference_factory(:author_name => 'Hölldobler')
            Sunspot.commit
            expect(Reference.perform_search(:fulltext => 'journal')).to eq([matching_reference])
          end
        end

        describe 'Publisher name' do
          it 'should find something in publisher name' do
            publisher = FactoryGirl.create :publisher, :name => 'Publisher'
            matching_reference = reference_factory(:author_name => 'Hölldobler', :publisher => publisher)
            unmatching_reference = reference_factory(:author_name => 'Hölldobler')
            Sunspot.commit
            expect(Reference.perform_search(:fulltext => 'Publisher')).to eq([matching_reference])
          end
        end

        describe 'Citation (for Unknown references)' do
          it 'should find something in citation' do
            matching_reference = reference_factory(:author_name => 'Hölldobler', :citation => 'Citation')
            unmatching_reference = reference_factory(:author_name => 'Hölldobler')
            Sunspot.commit
            expect(Reference.perform_search(:fulltext => 'Citation')).to eq([matching_reference])
          end
        end

        describe 'Year' do
          before do
            reference_factory(:author_name => 'Bolton', :citation_year => '1994')
            reference_factory(:author_name => 'Bolton', :citation_year => '1995')
            reference_factory(:author_name => 'Bolton', :citation_year => '1996')
            reference_factory(:author_name => 'Bolton', :citation_year => '1997')
            reference_factory(:author_name => 'Bolton', :citation_year => '1998')
            Sunspot.commit
          end
          it "should return an empty array if nothing is found for year" do
            expect(Reference.perform_search(:fulltext => '', :start_year => 1992, :end_year => 1993)).to be_empty
          end
          it "should find entries in between the start year and the end year (inclusive)" do
            expect(Reference.perform_search(:fulltext => '', :start_year => 1995, :end_year => 1996).map(&:year)).to match_array([1995, 1996])
          end
          it "should find references in the year of the end range, even if they have extra characters" do
            reference_factory(:author_name => 'Bolton', :citation_year => '2004.')
            Sunspot.commit
            expect(Reference.perform_search(:fulltext => '', :start_year => '2004').map(&:year)).to match_array([2004])
          end
        end

        describe "Year and fulltext" do
          it "should work" do
            atta2004 = FactoryGirl.create :book_reference, :title => 'Atta', :citation_year => '2004'
            atta2003 = FactoryGirl.create :book_reference, :title => 'Atta', :citation_year => '2003'
            formica2004 = FactoryGirl.create :book_reference, :title => 'Formica', :citation_year => '2003'
            Sunspot.commit
            expect(Reference.perform_search(:fulltext => 'atta', :start_year => 2004)).to eq([atta2004])
          end
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

        expect(Reference.perform_search(:order => :updated_at)).to eq([updated_today, updated_yesterday, updated_last_week])
      end

      it "should be able to sort by created_at" do
        Reference.record_timestamps = false
        created_yesterday = reference_factory(:author_name => 'Fisher', :citation_year => '1910b')
        created_yesterday.update_attribute(:created_at,  Time.now.yesterday)
        created_last_week = reference_factory(:author_name => 'Wheeler', :citation_year => '1874')
        created_last_week.update_attribute(:created_at,  1.week.ago)
        created_today = reference_factory(:author_name => 'Fisher', :citation_year => '1910a')
        created_today.update_attribute(:created_at,  Time.now)
        Reference.record_timestamps = true

        expect(Reference.perform_search(:order => :created_at)).to eq([created_today, created_yesterday, created_last_week])
      end

      describe "Default sort order" do
        it "should sort by author_name plus year plus letter" do
          fisher1910b = reference_factory(:author_name => 'Fisher', :citation_year => '1910b')
          wheeler1874 = reference_factory(:author_name => 'Wheeler', :citation_year => '1874')
          fisher1910a = reference_factory(:author_name => 'Fisher', :citation_year => '1910a')
          expect(Reference.perform_search).to eq([fisher1910a, fisher1910b, wheeler1874])
        end

        it "should sort by multiple author_names using their order in each reference" do
          a = FactoryGirl.create(:article_reference, :author_names => AuthorName.import_author_names_string('Abdalla, F. C.; Cruz-Landim, C. da.')[:author_names])
          m = FactoryGirl.create(:article_reference, :author_names => AuthorName.import_author_names_string('Mueller, U. G.; Mikheyev, A. S.; Abbot, P.')[:author_names])
          v = FactoryGirl.create(:article_reference, :author_names => AuthorName.import_author_names_string("Vinson, S. B.; MacKay, W. P.; Rebeles M.; A.; Arredondo B.; H. C.; Rodríguez R.; A. D.; González, D. A.")[:author_names])
          expect(Reference.perform_search).to eq([a, m, v])
        end

        it "should sort by multiple author_names using their order in each reference" do
          a = FactoryGirl.create(:article_reference, :author_names => AuthorName.import_author_names_string('Abdalla, F. C.; Cruz-Landim, C. da.')[:author_names])
          m = FactoryGirl.create(:article_reference, :author_names => AuthorName.import_author_names_string('Mueller, U. G.; Mikheyev, A. S.; Abbot, P.')[:author_names])
          v = FactoryGirl.create(:article_reference, :author_names => AuthorName.import_author_names_string("Vinson, S. B.; MacKay, W. P.; Rebeles M.; A.; Arredondo B.; H. C.; Rodríguez R.; A. D.; González, D. A.")[:author_names])
          expect(Reference.perform_search).to eq([a, m, v])
        end
      end

    end

    describe "Filtering", search: true do
      it "should apply the :unknown_references_only filter that's passed" do
        known = FactoryGirl.create :article_reference
        unknown = FactoryGirl.create :unknown_reference
        Sunspot.commit
        expect(Reference.perform_search(:fulltext => '', :filter => :unknown_references_only)).to eq([unknown])
      end
      it "should apply the :no_missing_references filter that's passed" do
        expect(MissingReference.count).to be > 0
        reference = FactoryGirl.create :article_reference
        Sunspot.commit
        expect(Reference.perform_search(:fulltext => '', :filter => :no_missing_references)).to eq([reference])
      end
      it "should apply the :nested_references_only filter that's passed" do
        nested = FactoryGirl.create :nested_reference
        unnested = FactoryGirl.create :unknown_reference
        Sunspot.commit
        expect(Reference.perform_search(:fulltext => '', :filter => :nested_references_only)).to eq([nested])
      end
    end

  end

  describe "Searching with Solr", search: true do
    it "should return an empty array if nothing is found for author_name" do
      FactoryGirl.create :reference
      expect(Reference.search {keywords 'foo'}.results).to be_empty
    end

    it "should find the reference for a given author_name if it exists" do
      reference = reference_factory(:author_name => 'Ward')
      reference_factory(:author_name => 'Fisher')
      Sunspot.commit
      expect(Reference.search {keywords 'Ward'}.results).to eq([reference])
    end

    it "should return an empty array if nothing is found for a given year and author_name" do
      reference_factory(:author_name => 'Bolton', :citation_year => '2010')
      reference_factory(:author_name => 'Bolton', :citation_year => '1995')
      reference_factory(:author_name => 'Fisher', :citation_year => '2011')
      reference_factory(:author_name => 'Fisher', :citation_year => '1996')
      #Sunspot.commit
      expect(Reference.search {
        with(:year).between(2012..2013)
        keywords 'Fisher'
      }.results).to be_empty
    end

    it "should return the one reference for a given year and author_name" do
      reference_factory(:author_name => 'Bolton', :citation_year => '2010')
      reference_factory(:author_name => 'Bolton', :citation_year => '1995')
      reference_factory(:author_name => 'Fisher', :citation_year => '2011')
      reference = reference_factory(:author_name => 'Fisher', :citation_year => '1996')
      Sunspot.commit
      expect(Reference.search {
        with(:year).between(1996..1996)
        keywords 'Fisher'
      }.results).to eq([reference])
    end

    it"should search citation year" do
      with_letter = reference_factory(:author_name => 'Bolton', :citation_year => '2010b')
      reference_factory(:author_name => 'Bolton', :citation_year => '2010')
      Sunspot.commit
      expect(Reference.search {
        keywords '2010b'
      }.results).to eq([with_letter])
    end

  end

  # this tests that Reference extracts the parameters correctly for perform_search
  describe "Do search" do

    describe "Searching for nothing" do
      it "should return everything" do
        expect(Reference).to receive(:perform_search).with page: 1, filter: :no_missing_references
        Reference.do_search
      end
    end

    describe "Review" do
      it "should sort by updated_at" do
        expect(Reference).to receive(:perform_search).with :order => :updated_at, :page => 1, filter: :no_missing_references
        Reference.do_search :review => true
      end
    end

    describe "New" do
      it "should sort by created_at" do
        expect(Reference).to receive(:perform_search).with :order => :created_at, :page => 1, filter: :no_missing_references
        Reference.do_search :whats_new => true
      end
    end

    describe "Searching for author(s)" do
      it "sends along the authors for the author names" do
        AuthorName.delete_all
        Author.delete_all
        bolton = FactoryGirl.create :author_name, :name => 'Bolton'
        fisher = FactoryGirl.create :author_name, :name => 'Fisher'
        bolton_b = FactoryGirl.create :author_name, :name => 'Bolton, B.', :author => bolton.author

        FactoryGirl.create :book_reference, :author_names => [bolton], :citation_year => '2001'
        FactoryGirl.create :book_reference, :author_names => [bolton_b], :citation_year => '2005'
        FactoryGirl.create :book_reference, :author_names => [fisher], :citation_year => '2003'

        expect(Reference).to receive(:perform_search) do |options|
          expect(options[:authors].size).to eq(2)
          expect(options[:authors].first).to eq(bolton.author)
          expect(options[:authors].second).to eq(fisher.author)
          expect(options[:page]).to eq(1)
        end

        Reference.do_search is_author_search:true, q:'Bolton; Fisher'
      end
    end

    describe "Searching for an ID" do
      it "should ignore everything else in the string if an id is provided" do
        expect(Reference).to receive(:perform_search).with :id => 12345
        Reference.do_search q: '12345 1972 Bolton'
      end
    end

    describe "Searching for text and/or years" do
      it "should extract the starting and ending years" do
        expect(Reference).to receive(:perform_search).with :fulltext => '', :start_year => 1992, :end_year => 1993, :page => 1, filter: :no_missing_references
        Reference.do_search q: '1992-1993'
      end

      it "extract the starting year" do
        expect(Reference).to receive(:perform_search).with :fulltext => '', :start_year => 1992, :page => 1, filter: :no_missing_references
        Reference.do_search q: '1992'
      end

      it "should convert the query string" do
        expect(Reference).to receive(:perform_search).with :fulltext => 'andre', :page => 1, filter: :no_missing_references
        Reference.do_search q: 'André'
      end

      it "should distinguish between years and citation years" do
        expect(Reference).to receive(:perform_search).with :fulltext => '1970a', :start_year => 1970, :page => 1, filter: :no_missing_references
        Reference.do_search q: '1970a 1970'
      end

      it "should not strip the year from the string" do
        string = '1990'
        Reference.do_search q: string
        expect(string).to eq('1990')
      end

    end

    describe "Pagination on or off for different search types" do
      it "should not paginate EndNote format" do
        expect(Reference).to receive(:perform_search).with fulltext: '', filter: :no_missing_references
        Reference.do_search q: '', format: :endnote_import
      end
      it "should paginate other formats" do
        expect(Reference).to receive(:perform_search).with fulltext: '', page: 1, filter: :no_missing_references
        Reference.do_search q: ''
      end
    end

    describe "Filtering unknown reference types" do
      it "should return only unknown reference types if a ? is passed as the search term" do
        expect(Reference).to receive(:perform_search).with :fulltext => 'monroe', :filter => :unknown_references_only, :page => 1
        Reference.do_search q: '? Monroe'
      end
    end

  end

  describe "Finding the reference for a Bolton citation" do
    it "creates a 'no Bolton' MissingReference if it can't find the reference" do
      reference = Reference.find_by_bolton_key :author_names => ['Bolton'], :year => '1920', :matched_text => 'Bolton, 1920'
      expect(reference.citation).to eq('Bolton, 1920')
      expect(reference.reason_missing).to eq('no Bolton')
    end
    it "creates a 'no Bolton match' MissingReference if the Bolton reference exists, but not the Reference" do
      bolton_reference = FactoryGirl.create :bolton_reference, :authors => 'Bolton, B.', :citation_year => '1920'
      data = {:author_names => ['Bolton'], :year => '1920', :matched_text => 'Bolton, 1920'}
      reference = Reference.find_by_bolton_key data
      expect(reference.reason_missing).to eq('no Bolton match')
    end
    it "creates a 'no year' MissingReference if the key doesn't have a year" do
      data = {author_names: ['Bolton'], matched_text: 'Bolton'}
      reference = Reference.find_by_bolton_key data
      expect(reference.reason_missing).to eq('no year')
    end
    it "reuses a MissingReference, even with no year" do
      missing_reference = MissingReference.create! title: '(missing)', citation: 'Fabricius'
      data = {author_names: ['Fabricius'], matched_text: 'Fabricius'}
      reference = Reference.find_by_bolton_key data
      expect(reference).to eq(missing_reference)
    end
    it "reuses a MissingReference" do
      data = {author_names: ['Bolton'], year: '1920', matched_text: 'Bolton, 1920'}
      reference = Reference.find_by_bolton_key data
      other_reference = Reference.find_by_bolton_key data
      expect(reference).to eq(other_reference)
    end
    it "uses the nesting_reference's year and author names" do
      data = {author_names: ['Bolton'], year: '1920', in: {author_names: ['Fisher'], year: '2013'}}
      author_names, year = Reference.get_author_names_and_year data
      expect(author_names).to eq(['Fisher'])
      expect(year).to eq('1920')
    end
  end

end