require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CitationParser do
  describe "actual parsed data results" do
    before :all do
      Factory :place, :name => 'Melbourne'
      Factory :place, :name => 'Leiden'
      Factory :place, :name => 'Cambridge, Mass.'
    end

    it 'should parse an article citation' do
      CitationParser.parse('Psyche 1:2').should ==
        {:article => {:journal => 'Psyche', :series_volume_issue => '1', :pagination => '2'}}
    end

    it 'should parse a book citation' do
      CitationParser.parse('Melbourne: CSIRO Publications, vii + 70 pp.').should ==
        {:book => {:publisher => {:name => 'CSIRO Publications', :place => 'Melbourne'}, :pagination => 'vii + 70 pp.'}}
    end

    it 'should parse a nested citation' do
      CitationParser.parse("Pp. 96-98 in: MacKay, W., Lowrie, D., Fisher, A., MacKay, E., Barnes, F., Lowrie, D. The ants of Los Alamos County, New Mexico (Hymenoptera: Formicidae). Pp. 79-131 in: Trager, J. C. (ed.) Advances in myrmecology. Leiden: E. J. Brill, xxvii + 551 pp.").should == {
        :nested => {
          :pages_in => 'Pp. 96-98 in:',
          :authors => ['MacKay, W.', 'Lowrie, D.', 'Fisher, A.', 'MacKay, E.', 'Barnes, F.', 'Lowrie, D.'],
          :title => 'The ants of Los Alamos County, New Mexico (Hymenoptera: Formicidae)',
          :nested => {
            :pages_in => 'Pp. 79-131 in:',
            :authors => ['Trager, J. C. (ed.)'],
            :title => 'Advances in myrmecology',
            :book => {:publisher => {:name => 'E. J. Brill', :place => 'Leiden'}, :pagination => 'xxvii + 551 pp.'}
          }
        }
      }
    end

    it 'should parse a completely unknown citation' do
      CitationParser.parse('A book.').should == {:other => 'A book'}
    end

    it "should not parse a completely unknown citation if it's possibly embedded" do
      CitationParser.parse('A book.', true).should_not be_true
    end

    it "should probably just call this one unknown" do
      CitationParser.parse("Journal of Insect Science 7(42), 14 pp. (available online: insectscience.org/7.42).").should ==
        {:other => "Journal of Insect Science 7(42), 14 pp. (available online: insectscience.org/7.42)"}
    end

    it "should work" do
      CitationParser.parse("Transactions of the Society for British Entomology 16:93-114,121").should ==
        {:article => {
          :journal => 'Transactions of the Society for British Entomology',
          :series_volume_issue => '16',
          :pagination => '93-114,121'}
        }
    end
  end
end
