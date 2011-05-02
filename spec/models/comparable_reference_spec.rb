require 'spec_helper'

describe ComparableReference do

  describe "type mismatch" do

    it "should never consider references of different types similar in the least" do
      lhs = ComparableReference.new :type => 'ArticleReference', :author => 'Fisher, B. L.', :title => 'Ants', :year => '1975'
      rhs = ComparableReference.new :type => 'NestedReference', :author => 'Fisher, B. L.', :title => 'Ants', :year => '1975'
      (lhs <=> rhs).should == 0.00
    end

  end

  describe "author + year matching" do
    describe "when the author names don't match but the years do" do
      before do
        @lhs = ComparableReference.new :year => 2010
        @rhs = ComparableReference.new :year => 2010
      end
      it "should not match if the author name is different" do
        @lhs.author = 'Fisher'
        @rhs.author = 'Bolton'
        (@lhs <=> @rhs).should == 0.00
      end
      it "should not match if the author name is a prefix" do
        @lhs.author = 'Fisher'
        @rhs.author = 'Fish'
        (@lhs <=> @rhs).should == 0.00
      end
    end
    describe 'when the author names match' do
      before do
        @lhs = ComparableReference.new :title => 'A', :author => 'Fisher, B. L.'
        @rhs = ComparableReference.new :title => 'B', :author => 'Fisher, B. L.'
      end
      it "should not match if the author name is the same but the year is different" do
        @lhs.year = '1970'
        @rhs.year = '1980'
        (@lhs <=> @rhs).should == 0.00
      end
      it "should match better if the author name matches and the year is within 1" do
        @lhs.year = '1979'
        @rhs.year = '1980'
        (@lhs <=> @rhs).should == 0.10
      end
      it "should match if the author names differ by accentation" do
        @lhs.update :author => 'Csösz', :year => '1979'
        @rhs.update :author => 'Csősz', :year => '1980'
        (@lhs <=> @rhs).should == 0.10
      end
      it "should match if the author names differ by case" do
        @lhs.update :author => 'MacKay', :year => '1979'
        @rhs.update :author => 'Mackay', :year => '1980'
        (@lhs <=> @rhs).should == 0.10
      end
    end
  end

  describe "title + year matching" do
    before do
      @lhs = ComparableReference.new :author => 'Fisher, B. L.'
      @rhs = ComparableReference.new :author => 'Fisher, B. L.'
    end

    it "should match with much less confidence if the author and title are the same but the year is not within 1" do
      @lhs.update :title => 'Ants', :year => '1975'
      @rhs.update :title => 'Ants', :year => '1971'
      (@lhs <=> @rhs).should == 0.50
    end


    describe "year is within 1" do
      before do
        @lhs.year = '1979'
        @rhs.year = '1980'
      end
      it "should match with complete confidence if the author and title are the same" do
        @lhs.title = 'Ants'
        @rhs.title = 'Ants'
        (@lhs <=> @rhs).should == 1.00
      end
      it "should match when lhs includes taxon names, as long as one of them is one we know about" do
        @rhs.title = 'The genus-group names of Symphyta and their type species'
        @lhs.title = 'The genus-group names of Symphyta (Hymenoptera: Formicidae) and their type species'
        (@lhs <=> @rhs).should == 1.00
      end
      it "should not match when the only difference is parenthetical, but is not a toxon name" do
        @rhs.title = 'The genus-group names of Symphyta and their type species'
        @lhs.title = 'The genus-group names of Symphyta (unknown) and their type species'
        (@lhs <=> @rhs).should == 0.10
      end
      it "should match when the only difference is accents" do
        @rhs.title = 'Sobre los caracteres morfólogicos de Goniomma, con algunas sugerencias sobre su taxonomia'
        @lhs.title =   'Sobre los caracteres morfólogicos de Goniomma, con algunas sugerencias sobre su taxonomía'
        (@lhs <=> @rhs).should == 1.00
      end
      it "should match when the only difference is case" do
        @rhs.title = 'Ants'
        @lhs.title =   'ANTS'
        (@lhs <=> @rhs).should == 1.00
      end
      it "should match when the only difference is punctuation" do
        @rhs.title = 'Sobre los caracteres morfólogicos de Goniomma, con algunas sugerencias sobre su taxonomia'
        @lhs.title =   'Sobre los caracteres morfólogicos de *Goniomma*, con algunas sugerencias sobre su taxonomía'
        (@lhs <=> @rhs).should == 1.00
      end
      it "should match when the only difference is in square brackets" do
        @rhs.title = 'Ants [sic] and pants'
        @lhs.title = 'Ants and pants [sic]'
        (@lhs <=> @rhs).should == 0.95
      end
      it "should not match when the whole title is square brackets" do
        @rhs.title = '[Ants and pants]'
        @lhs.title = '[Pants and ants]'
        (@lhs <=> @rhs).should == 0.10
      end

      describe 'replacing roman numerals with arabic' do
        it "should not replace roman numerals embedded in words" do
          @rhs.title = 'Indigenous'
          @lhs.title = '1ndigenous'
          (@lhs <=> @rhs).should == 0.10
        end
        it "should match with a little less confidence when roman numerals are replaced with arabic" do
          @rhs.title = 'Volume 1.'
          @lhs.title = 'Volume I.'
          (@lhs <=> @rhs).should == 0.94
        end
        it "should replace the longest roman numeral" do
          @rhs.title = 'Volume IV.'
          @lhs.title = 'Volume 4.'
          (@lhs <=> @rhs).should == 0.94
        end
      end
    end
  end

  describe 'matching book pagination with different titles' do
    before do
      @lhs = ComparableReference.new :author => 'Fisher', :title => 'Myrmicinae', :type => 'BookReference', :pagination => '1-76'
      @rhs = ComparableReference.new :author => 'Fisher', :title => 'Formica', :type => 'BookReference', :pagination => '1-76'
    end
    it 'should match with much less confidence when the year does not match' do
      @lhs.year = '1980'
      @rhs.year = '1990'
      (@lhs <=> @rhs).should be_within(0.001).of(0.30)
    end
    it "should match perfectly when the year does match" do
      @lhs.year = '1979'
      @rhs.year = '1980'
      (@lhs <=> @rhs).should == 0.80
    end
  end

  describe 'matching series/volume/issue + pagination with different titles' do
    before do
      @lhs = ComparableReference.new :author => 'Fisher', :title => 'Myrmicinae', :type => 'ArticleReference'
      @rhs = ComparableReference.new :author => 'Fisher', :title => 'Formica', :type => 'ArticleReference'
    end
    describe 'when the pagination matches' do
      before do
        @lhs.pagination = '1-76'
        @rhs.pagination = '1-76'
      end
      describe 'when the year does not match' do
        it 'should match with much less confidence' do
          @lhs.update :year => '1980', :series_volume_issue => '(21) 4'
          @rhs.update :year => '1990', :series_volume_issue => '(21) 4'
          (@lhs <=> @rhs).should == 0.40
        end
      end
      describe 'when the year matches' do
        before do
          @lhs.year = '1979'
          @rhs.year = '1980'
        end
        it "should match a perfect match" do
          @lhs.series_volume_issue = '(21) 4'
          @rhs.series_volume_issue = '(21) 4'
          (@lhs <=> @rhs).should == 0.90
        end
        it "should match when the series/volume/issue has spaces after the volume" do
          @lhs.series_volume_issue = '(21)4'
          @rhs.series_volume_issue = '(21) 4'
          (@lhs <=> @rhs).should == 0.90
        end
        it "should match when the series/volume/issue has spaces after the volume" do
          @lhs.series_volume_issue = '4(21)'
          @rhs.series_volume_issue = '4 (21)'
          (@lhs <=> @rhs).should == 0.90
        end
        it "should not match the series_volume_issue when the series/volume/issue has a space after the series, but the space separates words" do
          @lhs.series_volume_issue = '21 4'
          @rhs.series_volume_issue = '214'
          (@lhs <=> @rhs).should == 0.10
        end
        it "should match if the only difference is that rhs includes the year" do
          @lhs.series_volume_issue = '44'
          @rhs.series_volume_issue = '44 (1976)'
          (@lhs <=> @rhs).should == 0.90
        end
        it "should match if the only difference is that rhs uses 'No.'" do
          @lhs.series_volume_issue = '1976(1)'
          @rhs.series_volume_issue = '1976 (No. 1)'
          (@lhs <=> @rhs).should == 0.90
        end
        it "should match if the only difference is punctuation" do
          @lhs.series_volume_issue = ') 15'
          @rhs.series_volume_issue = '15'
          (@lhs <=> @rhs).should == 0.90
        end
      end
    end
  end
end
