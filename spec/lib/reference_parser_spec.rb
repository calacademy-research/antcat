require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ReferenceParser do

  describe 'parsing' do

    it "should not start a citation on a lowercase letter" do
      Factory :place, :name => 'Baltimore'
      ReferenceParser.parse("Ward, P. 2001. Title with. periods. Baltimore:Wiley, 32 pp.").should == {
        :authors => ['Ward, P.'],
        :authors_role => '',
        :year => '2001',
        :title => 'Title with. periods',
        :book => {
          :publisher => {:name => 'Wiley', :place => 'Baltimore'},
          :pagination => '32 pp.'
        }
      }
    end

    it 'should parse an article reference' do
      ReferenceParser.parse('Mayer, D.M. 1970. Ants. Psyche 1:2').should == {
        :authors => ['Mayer, D.M.'],
        :authors_role => '',
        :year => '1970',
        :title => 'Ants',
        :article => {
          :journal => 'Psyche',
          :series_volume_issue => '1',
          :pagination => '2',
        }
      }
    end
    
    it 'should parse a book reference' do
      ReferenceParser.parse('Ward, P.S., Fisher, B.L. 1981. Ants are my life. Melbourne: CSIRO Publications, vii + 70 pp.').should == {
        :authors => ['Ward, P.S.', 'Fisher, B.L.'],
        :authors_role => '',
        :year => '1981',
        :title => 'Ants are my life',
        :book => {
          :publisher => {:name => 'CSIRO Publications', :place => 'Melbourne'},
          :pagination => 'vii + 70 pp.',
        }
      }
    end

    it 'should parse a nested reference' do
      ReferenceParser.parse("MacKay, W. P. 1988. [Untitled. Pheidole wheelerorum W. MacKay new species.]. Pp. 96-98 in: MacKay, W., Lowrie, D., Fisher, A., MacKay, E., Barnes, F., Lowrie, D. The ants of Los Alamos County, New Mexico (Hymenoptera: Formicidae). Pp. 79-131 in: Trager, J. C. (ed.) Advances in myrmecology. Leiden: E. J. Brill, xxvii + 551 pp.").should == {
        :authors => ['MacKay, W. P.'],
        :authors_role => '',
        :year => '1988',
        :title => '[Untitled. Pheidole wheelerorum W. MacKay new species.]',
        :nested => {
          :pages_in => 'Pp. 96-98 in:',
          :authors => ['MacKay, W.', 'Lowrie, D.', 'Fisher, A.', 'MacKay, E.', 'Barnes, F.', 'Lowrie, D.'],
          :authors_role => '',
          :title => 'The ants of Los Alamos County, New Mexico (Hymenoptera: Formicidae)',
          :nested => {
            :pages_in => 'Pp. 79-131 in:',
            :authors => ['Trager, J. C.'],
            :authors_role => '(ed.)',
            :title => 'Advances in myrmecology',
            :book => {
              :publisher => {:name => 'E. J. Brill', :place => 'Leiden'},
              :pagination => 'xxvii + 551 pp.'
            }
          }
        }
      }
    end

    it 'should parse a CD-ROM reference' do
      ReferenceParser.parse('Bolton, B.; Alpert, G.; Ward, P. S.; Nasrecki, P. 2006. Bolton’s Catalogue of ants of the world. Cambridge, Mass.: Harvard University Press, CD-ROM.').should == {
        :authors => ['Bolton, B.', 'Alpert, G.', 'Ward, P. S.', 'Nasrecki, P.'],
        :authors_role => '',
        :year => '2006',
        :title => 'Bolton’s Catalogue of ants of the world',
        :unknown => 'Cambridge, Mass.: Harvard University Press, CD-ROM'
      }
    end

    it 'should parse a completely unknown reference' do
      ReferenceParser.parse('Bolton, B. 2006. Ants. A book.').should ==
        {:authors => ['Bolton, B.'], :authors_role => '', :year => '2006', :title => 'Ants', :unknown => 'A book'}
    end

    it "actually can handle this mess!" do
      ReferenceParser.parse('Bolton, B. 2006. Taxonomy, phylogeny: Philip Jr., 1904-1983. Series Entomologica (Dordrecht) 33:1-514.').should ==
        {:authors => ['Bolton, B.'], :authors_role => '', :year => '2006', :title => 'Taxonomy, phylogeny: Philip Jr., 1904-1983',
         :article => {:journal => "Series Entomologica (Dordrecht)", :series_volume_issue => "33", :pagination => '1-514'}}
    end

    it "grabs the first sentence without a period as the journal name" do
      ReferenceParser.parse("Ward, P. 1980. Ameisen aus Sao Paulo (Brasilien), Paraguay etc. gesammelt von Prof. Herm. v. Ihering, Dr. Lutz, Dr. Fiebrig, etc. Verhandlungen der Kaiserlich-Königlichen Zoologisch-Botanischen Gesellschaft in Wien 58:340-418").should == {
        :authors => ['Ward, P.'],
        :authors_role => '',
        :year => '1980',
        :title => 'Ameisen aus Sao Paulo (Brasilien), Paraguay etc. gesammelt von Prof. Herm. v. Ihering, Dr. Lutz, Dr. Fiebrig, etc',
        :article => {
          :journal => 'Verhandlungen der Kaiserlich-Königlichen Zoologisch-Botanischen Gesellschaft in Wien',
          :series_volume_issue => '58',
          :pagination => '340-418'}
      }
    end

  end


end
