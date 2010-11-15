require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Reference do
  before :each do
    @authors = [Factory :author]
  end

  describe "importing a new reference" do
    before do
      @reference_data = {
        :authors => ['Author'],
        :authors_suffix => ' (eds.)',
        :citation_year => '2010d',
        :title => 'Ants',
        :cite_code => '345',
        :possess => 'PSW',
        :date => '120134',
        :public_notes => 'Notes',
        :editor_notes => 'Editor notes',
        :taxonomic_notes => 'Tax. notes',
        :id => 1,
        :class => 'WardReference', 
      }
    end
    it "should import a book reference" do
      author = mock_model Author
      Author.should_receive(:import).with(['Author']).and_return [author]
      @reference_data[:book] = 1
      BookReference.should_receive(:import).with({
        :authors => [author],
        :authors_suffix => ' (eds.)',
        :citation_year => '2010d',
        :title => 'Ants',
        :cite_code => '345',
        :possess => 'PSW',
        :date => '120134',
        :public_notes => 'Notes',
        :editor_notes => 'Editor notes',
        :taxonomic_notes => 'Tax. notes',
        :source_reference_id => 1,
        :source_reference_type => 'WardReference'}, 1)
        Reference.import @reference_data
    end
    it "should import an article reference" do
      author = mock_model Author
      Author.should_receive(:import).with(['Author']).and_return [author]
      @reference_data[:article] = 1
      ArticleReference.should_receive(:import).with({
        :authors => [author],
        :authors_suffix => ' (eds.)',
        :citation_year => '2010d',
        :title => 'Ants',
        :cite_code => '345',
        :possess => 'PSW',
        :date => '120134',
        :public_notes => 'Notes',
        :editor_notes => 'Editor notes',
        :taxonomic_notes => 'Tax. notes',
        :source_reference_id => 1,
        :source_reference_type => 'WardReference'}, 1)
        Reference.import @reference_data
    end
    it "should import a nested reference" do
      author = mock_model Author
      Author.should_receive(:import).with(['Author']).and_return [author]
      @reference_data[:nested] = 'nested'
      NestedReference.should_receive(:import).with({
        :authors => [author],
        :authors_suffix => ' (eds.)',
        :citation_year => '2010d',
        :title => 'Ants',
        :cite_code => '345',
        :possess => 'PSW',
        :date => '120134',
        :public_notes => 'Notes',
        :editor_notes => 'Editor notes',
        :taxonomic_notes => 'Tax. notes',
        :source_reference_id => 1,
        :source_reference_type => 'WardReference'}, 'nested')
        Reference.import @reference_data
    end
    it "should import an unknown reference" do
      author = mock_model Author
      Author.should_receive(:import).with(['Author']).and_return [author]
      @reference_data[:unknown] = 'other'
      UnknownReference.should_receive(:import).with({
        :authors => [author],
        :authors_suffix => ' (eds.)',
        :citation_year => '2010d',
        :title => 'Ants',
        :cite_code => '345',
        :possess => 'PSW',
        :date => '120134',
        :public_notes => 'Notes',
        :editor_notes => 'Editor notes',
        :taxonomic_notes => 'Tax. notes',
        :source_reference_id => 1,
        :source_reference_type => 'WardReference'}, 'other')
        Reference.import @reference_data
    end

    it "should not import the same reference twice" do
      author = Factory :author
      reference = Reference.create! :title => 'Ants', :authors => [author], :citation_year => '2010d', :pagination => '2 pp.'
      Reference.import(
        :authors => [author.name],
        :authors_suffix => ' (eds.)',
        :citation_year => '2010',
        :title => 'Ants',
        :unknown => 'Other citation',
        :cite_code => '345',
        :possess => 'PSW',
        :date => '120134',
        :public_notes => 'Notes',
        :editor_notes => 'Editor notes',
        :taxonomic_notes => 'Taxonomic notes',
        :taxonomic_notes => 'Tax. notes',
        :source_reference_id => 1,
        :source_reference_type => 'WardReference')
      Reference.count.should == 1
    end
  end

  describe "searching" do
    it "should return an empty array if nothing is found for author" do
      Factory(:reference).index!
      Reference.search {keywords 'foo'}.results.should be_empty
    end

    it "should find the reference for a given author if it exists" do
      reference = reference_factory(:author => 'Bolton')
      reference_factory(:author => 'Fisher')
      Reference.reindex
      Reference.search {keywords 'Bolton'}.results.should == [reference]
    end

    it "should return an empty array if nothing is found for a given year and author" do
      reference_factory(:author => 'Bolton', :citation_year => '2010').index
      reference_factory(:author => 'Bolton', :citation_year => '1995').index
      reference_factory(:author => 'Fisher', :citation_year => '2011').index
      reference_factory(:author => 'Fisher', :citation_year => '1996').index
      Sunspot.commit
      Reference.search {
        with(:year).between(2012..2013)
        keywords 'Fisher'
      }.results.should be_empty
    end

    it "should return the one reference for a given year and author" do
      reference_factory(:author => 'Bolton', :citation_year => '2010').index
      reference_factory(:author => 'Bolton', :citation_year => '1995').index
      reference_factory(:author => 'Fisher', :citation_year => '2011').index
      reference = reference_factory(:author => 'Fisher', :citation_year => '1996')
      reference.index
      Sunspot.commit
      Reference.search {
        with(:year).between(1996..1996)
        keywords 'Fisher'
      }.results.should == [reference]
    end

    describe "search" do
      it "should not strip the year from the string" do
        string = '1990'
        Reference.do_search string
        string.should == '1990'
      end

      describe 'searching by author' do
        it 'should at least find Bert!' do
          reference = reference_factory(:author => 'Hölldobler')
          Reference.reindex
          Reference.do_search('holldobler').should == [reference]
        end
      end

      describe 'searching by cite code' do
        it "should find a cite code that's doesn't look like a current year" do
          matching_reference = reference_factory(:author => 'Hölldobler', :cite_code => 'abcdef')
          unmatching_reference = reference_factory(:author => 'Hölldobler', :cite_code => 'fedcba')
          Reference.reindex
          Reference.do_search('abcdef').should == [matching_reference]
        end

        it "should find a cite code that looks like a year, but not a current year" do
          matching_reference = reference_factory(:author => 'Hölldobler', :cite_code => '1600')
          Reference.reindex
          Reference.do_search('1600').should == [matching_reference]
        end
      end

      describe 'searching by year' do
        before do
          reference_factory(:author => 'Bolton', :citation_year => '1994')
          reference_factory(:author => 'Bolton', :citation_year => '1995')
          reference_factory(:author => 'Bolton', :citation_year => '1996')
          reference_factory(:author => 'Bolton', :citation_year => '1997')
          reference_factory(:author => 'Bolton', :citation_year => '1998')
          Reference.reindex
        end

        it "should return an empty array if nothing is found for year" do
          Reference.do_search('1992-1993').should be_empty
        end

        it "should find entries in between the start year and the end year (inclusive)" do
          Reference.do_search('1995-1996').map(&:year).should =~ [1995, 1996]
        end

        it "should find references in the year of the end range, even if they have extra characters" do
          reference_factory(:author => 'Bolton', :citation_year => '2004.').index!
          Reference.do_search('2004').map(&:year).should =~ [2004]
        end
      end

      describe "sorting search results" do
        it "should sort by author plus year plus letter" do
          fisher1910b = reference_factory(:author => 'Fisher', :citation_year => '1910b')
          wheeler1874 = reference_factory(:author => 'Wheeler', :citation_year => '1874')
          fisher1910a = reference_factory(:author => 'Fisher', :citation_year => '1910a')
          Reference.reindex
          Reference.do_search.should == [fisher1910a, fisher1910b, wheeler1874]
        end

        it "should sort by multiple authors using their order in each reference" do
          a = ward_reference_factory(:authors => 'Abdalla, F. C.; Cruz-Landim, C. da.', :citation => 'Ants 2:2')
          m = ward_reference_factory(:authors => 'Mueller, U. G.; Mikheyev, A. S.; Abbot, P.', :citation => 'Ants 3:3')
          v = ward_reference_factory(:authors => "Vinson, S. B.; MacKay, W. P.; Rebeles M.; A.; Arredondo B.; H. C.; Rodríguez R.; A. D.; González, D. A.",
                                    :citation => 'Ants 1:1')
          Reference.reindex
          Reference.do_search.should == [a, m, v]
        end
      end
    end
  end

  it "has many authors" do
    reference = Reference.create! :authors => @authors, :title => 'asdf', :citation_year => '2010d'
    reference.authors.first.should == @authors.first
  end

  describe "authors_string" do
    describe "formatting" do
      it "should consist of one author if that's all there is" do
        @reference = Factory(:reference, :authors => [Factory(:author, :name => 'Fisher, B.L.')])
        @reference.authors_string.should == 'Fisher, B.L.'
      end

      it "should separate multiple authors with semicolons" do
        authors = [Factory(:author, :name => 'Fisher, B.L.'), Factory(:author, :name => 'Ward, P.S.')]
        @reference = Factory(:reference, :authors => authors)
        @reference.authors_string.should == 'Fisher, B.L.; Ward, P.S.'
      end

      it "should include the authors' suffix" do
        authors = [Factory(:author, :name => 'Fisher, B.L.'), Factory(:author, :name => 'Ward, P.S.')]
        @reference = Reference.create! :title => 'Ants', :citation_year => '2010', :authors => authors, :authors_suffix => ' (eds.)'
        @reference.authors_string.should == 'Fisher, B.L.; Ward, P.S. (eds.)'
      end
    end

    describe "updating, when things change" do
      before do
        @reference = Factory(:reference, :authors => [Factory(:author, :name => 'Fisher, B.L.')])
      end
      it "should update its authors_string when an author is added" do
        @reference.authors << Factory(:author, :name => 'Ward')
        @reference.authors_string.should == 'Fisher, B.L.; Ward'
      end
      it "should update its authors_string when an author is removed" do
        author = Factory(:author, :name => 'Ward')
        @reference.authors << author
        @reference.authors_string.should == 'Fisher, B.L.; Ward'
        @reference.authors.delete author
        @reference.authors_string.should == 'Fisher, B.L.'
      end
      it "should update its authors_string when an author's name is changed" do
        author = Factory(:author, :name => 'Ward')
        @reference.authors = [author]
        @reference.authors_string.should == 'Ward'
        author.update_attribute :name, 'Fisher'
        @reference.reload.authors_string.should == 'Fisher'
      end
      it "should update its authors_string when the authors_suffix changes" do
        @reference.authors_suffix = ' (eds.)'
        @reference.save
        @reference.reload.authors_string.should == 'Fisher, B.L. (eds.)'
      end
    end

    describe "maintaining its order" do
      it "should show the authors in the order in which they were added to the reference" do
        reference = Factory(:reference, :authors => [Author.create!(:name => 'Ward')])
        wilden = Author.create!(:name => 'Wilden')
        fisher = Author.create!(:name => 'Fisher')
        reference.authors << wilden
        reference.authors << fisher
        reference.authors_string.should == 'Ward; Wilden; Fisher'
      end
    end
  end

  describe "validations" do
    before do
      author = Factory :author
      @reference = Reference.new :authors => [author], :title => 'title', :citation_year => '1910'
    end

    it "should be OK when all fields are present" do
      @reference.should be_valid
    end

    it "should not be OK when the title is missing" do
      @reference.title = nil
      @reference.should_not be_valid
    end

    it "should not be OK when the citation year is missing" do
      @reference.citation_year = nil
      @reference.should_not be_valid
    end

    it "should not be OK when the citation year is blank" do
      @reference.citation_year = ''
      @reference.should_not be_valid
    end

  end

  describe "changing the citation year" do
    it "should change the year" do
      reference = Factory(:reference, :citation_year => '1910a')
      reference.year.should == 1910
      reference.citation_year = '2010b'
      reference.save!
      reference.year.should == 2010
    end

    it "should set the year to the stated year, if present" do
      reference = Factory(:reference, :citation_year => '1910a ["1958"]')
      reference.year.should == 1958
      reference.citation_year = '2010b'
      reference.save!
      reference.year.should == 2010
    end
  end

  describe "source_url" do
    before do
      @author = Factory :author
    end
    it "should make sure it has a protocol" do
      FakeWeb.register_uri(:any, "http://1.pdf", :body => "Hello World!")
      reference = Factory :reference
      reference.source_url = '1.pdf'
      reference.save!
      reference.reload.source_url.should == 'http://1.pdf'
      reference.save!
      reference.reload.source_url.should == 'http://1.pdf'
    end

    it "should make sure it's a valid URL" do
      reference = Reference.new :authors => [@author], :title => 'title', :citation_year => '1910', :source_url => '*'
      reference.should_not be_valid
      reference.errors.full_messages.should =~ ['Source url is not in a valid format']
    end

    it "should make sure it exists" do
      FakeWeb.register_uri(:any, "http://1.pdf", :body => "Hello World!")
      reference = Reference.new :authors => [@author], :title => 'title', :citation_year => '1910', :source_url => '1.pdf'
      reference.should be_valid
      FakeWeb.register_uri(:any, "http://1.pdf", :status => ["404", "Not Found"])
      reference.should_not be_valid
    end

    it "should say that it's not hosted by us when the source URL is blank" do
      reference = Factory :reference
      reference.should_not be_hosted_by_us 'antcat.local'
    end

    it "should know when it's not hosted by us" do
      reference = Factory :reference
      reference.update_attribute :source_url, 'http://antbase.org/pdfs/23/3242.pdf'
      reference.should_not be_hosted_by_us 'antcat.local'
    end

    it "should know when it is hosted by us" do
      reference = Factory :reference
      reference.update_attribute :source_url, 'http://antcat.org/sources/1.pdf'
      reference.should be_hosted_by_us 'antcat.org'
    end

  end

  describe "entering a newline in the title, public_notes, editor_notes or taxonomic_notes" do
    it "should strip the newline" do
      reference = Factory :reference
      reference.title = 'A\nB'
      reference.public_notes = "A\nB"
      reference.editor_notes = "A\nB"
      reference.taxonomic_notes = "A\nB"
      reference.save!
      reference.public_notes.should == "A B"
      reference.editor_notes.should == "A B"
      reference.taxonomic_notes.should == "A B"
    end
  end

  describe "polymorphic association to source of reference" do
    it "should work" do
      ward_reference = Factory(:ward_reference)
      reference = Reference.create! :authors => @authors, :source_reference => ward_reference, :title => 'asdf', :citation_year => '2010'
      reference.reload.source_reference.should == ward_reference
    end
  end

  it "should not truncate long fields" do
    Reference.create! :authors => @authors, :editor_notes => 'e' * 1000, :citation => 'c' * 2000,
      :public_notes => 'n' * 1500, :taxonomic_notes => 't' * 1700, :title => 't' * 1900, :citation_year => '2010'
    reference = Reference.first
    reference.citation.length.should == 2000
    reference.editor_notes.length.should == 1000
    reference.public_notes.length.should == 1500
    reference.taxonomic_notes.length.should == 1700
    reference.title.length.should == 1900
  end

  describe "importing PDF links" do
    it "should delegate to the right object" do
      mock = mock HolSourceUrlImporter
      HolSourceUrlImporter.should_receive(:new).and_return mock
      mock.should_receive(:import)
      Reference.import_hol_source_urls
    end
  end

  describe "ordering by author" do
    it "should order by author" do
      bolton = Factory :author, :name => 'Bolton'
      ward = Factory :author, :name => 'Ward'
      fisher = Factory :author, :name => 'Fisher'
      bolton_reference = Factory :reference, :authors => [bolton, ward]
      first_ward_reference = Factory :reference, :authors => [ward, bolton]
      second_ward_reference = Factory :reference, :authors => [ward, fisher]
      fisher_reference = Factory :reference, :authors => [fisher, bolton]

      Reference.sorted_by_author.map(&:id).should == [bolton_reference.id, fisher_reference.id, first_ward_reference.id, second_ward_reference.id]
    end
  end

end
