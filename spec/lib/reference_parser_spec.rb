require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ReferenceParser do

  describe 'parsing' do

    it "should not start a citation on a lowercase letter" do
      ReferenceParser.parse("Ward, P. 2001. Title with. periods. Baltimore:Wiley, 32 pp.").should == {
        :authors => ['Ward, P.'],
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
        :year => '1988',
        :title => '[Untitled. Pheidole wheelerorum W. MacKay new species.]',
        :nested => {
          :pages_in => 'Pp. 96-98 in:',
          :authors => ['MacKay, W.', 'Lowrie, D.', 'Fisher, A.', 'MacKay, E.', 'Barnes, F.', 'Lowrie, D.'],
          :title => 'The ants of Los Alamos County, New Mexico (Hymenoptera: Formicidae)',
          :nested => {
            :pages_in => 'Pp. 79-131 in:',
            :authors => ['Trager, J. C. (ed.)'],
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
        :year => '2006',
        :title => 'Bolton’s Catalogue of ants of the world',
        :other => 'Cambridge, Mass.: Harvard University Press, CD-ROM'
      }
    end

    it 'should parse a completely unknown reference' do
      ReferenceParser.parse('Bolton, B. 2006. Ants. A book.').should ==
        {:authors => ['Bolton, B.'], :year => '2006', :title => 'Ants', :other => 'A book'}
    end

    it "actually can handle this mess!" do
      ReferenceParser.parse('Bolton, B. 2006. Taxonomy, phylogeny: Philip Jr., 1904-1983. Series Entomologica (Dordrecht) 33:1-514.').should ==
        {:authors => ['Bolton, B.'], :year => '2006', :title => 'Taxonomy, phylogeny: Philip Jr., 1904-1983',
         :article => {:journal => "Series Entomologica (Dordrecht)", :series_volume_issue => "33", :pagination => '1-514'}}
    end

    it "can't really help parsing this as an article reference" do
      ReferenceParser.parse("Ward, P. 1980. Ameisen aus Sao Paulo (Brasilien), Paraguay etc. gesammelt von Prof. Herm. v. Ihering, Dr. Lutz, Dr. Fiebrig, etc. Verhandlungen der Kaiserlich-Königlichen Zoologisch-Botanischen Gesellschaft in Wien 58:340-418").should == {
        :authors => ['Ward, P.'],
        :year => '1980',
        :title => 'Ameisen aus Sao Paulo (Brasilien), Paraguay etc. gesammelt von Prof',
        :article => {
          :journal => 'Herm. v. Ihering, Dr. Lutz, Dr. Fiebrig, etc. Verhandlungen der Kaiserlich-Königlichen Zoologisch-Botanischen Gesellschaft in Wien',
          :series_volume_issue => '58',
          :pagination => '340-418'}
      }
    end

  end

  describe "parsing a citation" do
    it 'should parse an article citation' do
      ReferenceParser.parse_citation('Psyche 1:2').should ==
        {:article => {:journal => 'Psyche', :series_volume_issue => '1', :pagination => '2'}}
    end

    it 'should parse a book citation' do
      ReferenceParser.parse_citation('Melbourne: CSIRO Publications, vii + 70 pp.').should ==
        {:book => {:publisher => {:name => 'CSIRO Publications', :place => 'Melbourne'}, :pagination => 'vii + 70 pp.'}}
    end

    it 'should parse a nested citation' do
      ReferenceParser.parse_citation("Pp. 96-98 in: MacKay, W., Lowrie, D., Fisher, A., MacKay, E., Barnes, F., Lowrie, D. The ants of Los Alamos County, New Mexico (Hymenoptera: Formicidae). Pp. 79-131 in: Trager, J. C. (ed.) Advances in myrmecology. Leiden: E. J. Brill, xxvii + 551 pp.").should == {
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

    it 'should parse a CD-ROM citation' do
      ReferenceParser.parse_citation('Cambridge, Mass.: Harvard University Press, CD-ROM.').should ==
        {:other => 'Cambridge, Mass.: Harvard University Press, CD-ROM'}
    end

    it 'should parse a completely unknown citation' do
      ReferenceParser.parse_citation('A book.').should == {:other => 'A book'}
    end

  end

end
