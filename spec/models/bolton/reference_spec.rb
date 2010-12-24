require 'spec_helper'

describe Bolton::Reference do

  describe "string representation" do
    it "should be readable and informative" do
      bolton = Bolton::Reference.new :authors => 'Allred, D.M.', :title => "Ants of Utah", :year => 1982
      bolton.to_s.should == "Allred, D.M. 1982. Ants of Utah."
    end
  end

  describe "changing the citation year" do
    it "should change the year" do
      reference = Factory :bolton_reference, :citation_year => '1910a'
      reference.year.should == 1910
      reference.citation_year = '2010b'
      reference.save!
      reference.year.should == 2010
    end

    it "should set the year to the stated year, if present" do
      reference = Factory :bolton_reference, :citation_year => '1910a ["1958"]'
      reference.year.should == 1958
      reference.citation_year = '2010b'
      reference.save!
      reference.year.should == 2010
    end
  end

  describe 'last name of principal author' do
    it 'should work' do
      Bolton::Reference.new(:authors => 'Bolton, B.').principal_author_last_name.should == 'Bolton'
    end
  end

  describe 'matching against Ward' do
    before do
      @fisher = Factory :author_name, :name => 'Fisher, B. L.'
    end

    describe "author + year matching" do
      before do
        @ward = Factory :reference, :title => 'Myrmicinae'
        @bolton = Factory :bolton_reference, :title => 'Dolichoderinae'
      end
      describe "when the author names don't match" do
        it "should not match if the author name is different" do
          @ward.update_attributes :author_names => [@fisher]
          @bolton.update_attributes :authors => 'Ward, P. S.'
          @bolton.match(@ward).should == 0
        end
        it "should not match if the author name is a prefix" do
          @ward.update_attributes :author_names => [Factory :author_name, :name => 'Fish, B. L.']
          @bolton.update_attributes :authors => 'Fisher, B. L.'
          @bolton.match(@ward).should == 0
        end
      end
      describe 'when the author names match' do
        before do
          @ward.update_attributes :author_names => [@fisher]
          @bolton.update_attributes :authors => @fisher.name
        end
        it "should not match if the author name is the same but the year is different" do
          @ward.update_attributes :citation_year => '1970'
          @bolton.update_attributes :citation_year => '1980'
          @bolton.match(@ward).should == 0
        end
        it "should match better if the author name matches and the year is within 1" do
          @ward.update_attributes :citation_year => '1979'
          @bolton.update_attributes :citation_year => '1980'
          @bolton.match(@ward).should == 10
        end
      end
    end

    describe "title + year matching" do
      before do
        @ward = Factory :reference, :author_names => [@fisher]
        @bolton = Factory :bolton_reference, :authors => @fisher.name
      end

      it "should match with much less confidence if the author and title are the same but the year is not within 1" do
        @ward.update_attributes :title => 'Ants', :citation_year => '1975'
        @bolton.update_attributes :title => 'Ants', :citation_year => '1971'
        @bolton.match(@ward).should == 50
      end

      describe "year is within 1" do
        before do
          @ward.update_attributes :citation_year => '1979'
          @bolton.update_attributes :citation_year => '1980'
        end
        it "should match with complete confidence if the author and title are the same" do
          @ward.update_attributes :title => 'Ants'
          @bolton.update_attributes :title => 'Ants'
          @bolton.match(@ward).should == 100
        end
          it "should match when Ward includes taxon names, as long as one of them is one we know about" do
          @bolton.update_attributes :title => 'The genus-group names of Symphyta and their type species'
          @ward.update_attributes :title => 'The genus-group names of Symphyta (Hymenoptera: Formicidae) and their type species'
          @bolton.match(@ward).should be == 100
        end
        it "should not match when the only difference is parenthetical, but is not a toxon name" do
          @bolton.update_attributes :title => 'The genus-group names of Symphyta and their type species'
          @ward.update_attributes :title => 'The genus-group names of Symphyta (unknown) and their type species'
          @bolton.match(@ward).should be == 10
        end
        it "should match when the only difference is accents" do
          @bolton.update_attributes :title => 'Sobre los caracteres morfólogicos de Goniomma, con algunas sugerencias sobre su taxonomia'
          @ward.update_attributes :title =>   'Sobre los caracteres morfólogicos de Goniomma, con algunas sugerencias sobre su taxonomía'
          @bolton.match(@ward).should be == 100
        end
        it "should match when the only difference is case" do
          @bolton.update_attributes :title => 'Ants'
          @ward.update_attributes :title =>   'ANTS'
          @bolton.match(@ward).should be == 100
        end
        it "should match when the only difference is punctuation" do
          @bolton.update_attributes :title => 'Sobre los caracteres morfólogicos de Goniomma, con algunas sugerencias sobre su taxonomia'
          @ward.update_attributes :title =>   'Sobre los caracteres morfólogicos de *Goniomma*, con algunas sugerencias sobre su taxonomía'
          @bolton.match(@ward).should be == 100
        end
        it "should match when the only difference is in square brackets" do
          @bolton.update_attributes :title => 'Ants [sic] and pants'
          @ward.update_attributes :title => 'Ants and pants [sic]'
          @bolton.match(@ward).should be == 95
        end
      end
    end

    describe 'matching book pagination with different titles' do
      before do
        @ward = Factory :book_reference, :author_names => [@fisher], :title => 'Myrmicinae'
        @bolton = Factory :bolton_reference, :authors => @fisher.name, :title => 'Formica', :reference_type => 'BookReference'
      end
      describe 'when the pagination matches' do
        before do
          @ward.update_attributes :pagination => '1-76'
          @bolton.update_attributes :pagination => '1-76'
        end
        describe 'when the year does not match' do
          it 'should match with much less confidence' do
            @ward.update_attributes :citation_year => '1980'
            @bolton.update_attributes :citation_year => '1990'
            @bolton.match(@ward).should be == 30
          end
        end
        describe 'when the year matches' do
          before do
            @ward.update_attributes :citation_year => '1979'
            @bolton.update_attributes :citation_year => '1980'
          end
          it "should match a perfect match" do
            @bolton.match(@ward).should be == 80
          end
        end
      end
    end

    describe 'matching series/volume/issue + pagination with different titles' do
      before do
        @ward = Factory :article_reference, :author_names => [@fisher], :title => 'Myrmicinae'
        @bolton = Factory :bolton_reference, :authors => @fisher.name, :title => 'Formica', :reference_type => 'ArticleReference'
      end
      describe 'when the pagination matches' do
        before do
          @ward.update_attributes :pagination => '1-76'
          @bolton.update_attributes :pagination => '1-76'
        end
        describe 'when the year does not match' do
          it 'should match with much less confidence' do
            @ward.update_attributes :citation_year => '1980', :series_volume_issue => '(21) 4'
            @bolton.update_attributes :citation_year => '1990', :series_volume_issue => '(21) 4'
            @bolton.match(@ward).should be == 40
          end
        end
        describe 'when the year matches' do
          before do
            @ward.update_attributes :citation_year => '1979'
            @bolton.update_attributes :citation_year => '1980'
          end
          it "should match a perfect match" do
            @ward.update_attributes :series_volume_issue => '(21) 4'
            @bolton.update_attributes :series_volume_issue => '(21) 4'
            @bolton.match(@ward).should be == 90
          end
          it "should match when the series/volume/issue has spaces after the volume" do
            @ward.update_attributes :series_volume_issue => '(21)4'
            @bolton.update_attributes :series_volume_issue => '(21) 4'
            @bolton.match(@ward).should be == 90
          end
          it "should match when the series/volume/issue has spaces after the volume" do
            @ward.update_attributes :series_volume_issue => '4(21)'
            @bolton.update_attributes :series_volume_issue => '4 (21)'
            @bolton.match(@ward).should be == 90
          end
          it "should not match the series_volume_issue when the series/volume/issue has a space after the series, but the space separates words" do
            @ward.update_attributes :series_volume_issue => '21 4'
            @bolton.update_attributes :series_volume_issue => '214'
            @bolton.match(@ward).should be == 10
          end
          it "should match if the only difference is that Bolton includes the year" do
            @ward.update_attributes :series_volume_issue => '44'
            @bolton.update_attributes :series_volume_issue => '44 (1976)'
            @bolton.match(@ward).should be == 90
          end
          it "should match if the only difference is that Bolton uses 'No.'" do
            @ward.update_attributes :series_volume_issue => '1976(1)'
            @bolton.update_attributes :series_volume_issue => '1976 (No. 1)'
            @bolton.match(@ward).should be == 90
          end
        end
      end
    end

  end
end
