require 'spec_helper'

describe Bolton::GenusCatalogParser do
  it 'should handle a blank line' do
    Bolton::GenusCatalogParser.parse("\n").should == :blank_line
  end

  it 'should handle complete garbage' do
    line = %{asdfj;jsdf}
    Bolton::GenusCatalogParser.parse(line).should == {:type => :not_understood}
  end

  it 'should handle all sorts of guff within the tags' do
    line = %{<b
      style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
      style='color:red'>ACANTHOGNATHUS</span></i></b> [Myrmicinae: Dacetini]}
    Bolton::GenusCatalogParser.parse(line).should == {:type => :genus, :name => 'Acanthognathus',
                                                      :subfamily => 'Myrmicinae', :tribe => 'Dacetini', :status => :valid}
  end

  describe 'parsing the genus name' do
    it 'should parse a normal genus name' do
      line = %{<b><i><span style='color:red'>ACANTHOGNATHUS</span></i></b> [Myrmicinae: Dacetini]}
      Bolton::GenusCatalogParser.parse(line).should == {:type => :genus, :name => 'Acanthognathus',
                                                        :subfamily => 'Myrmicinae', :tribe => 'Dacetini', :status => :valid}
    end

    it 'should parse a fossil genus name' do
      line = %{*<b><i><span style='color:red'>ACANTHOGNATHUS</span></i></b> [Myrmicinae: Dacetini]}
      Bolton::GenusCatalogParser.parse(line).should == {:type => :genus, :name => 'Acanthognathus',
                                                        :subfamily => 'Myrmicinae', :tribe => 'Dacetini', :fossil => true, :status => :valid}
    end

    it 'should parse an unidentifiable genus name' do
      line = %{*<b><i><span style='color:green'>ATTAICHNUS</span></i></b> [Myrmicinae: Attini]}
      Bolton::GenusCatalogParser.parse(line).should == {:type => :genus, :name => 'Attaichnus', :status => :unidentifiable,
                                                        :subfamily => 'Myrmicinae', :tribe => 'Attini', :fossil => true}
    end

    it 'should handle parens instead of brackets' do
      line = %{<b><i><span style='color:red'>ACROMYRMEX</span></i></b> (Myrmicinae: Attini)}
      Bolton::GenusCatalogParser.parse(line).should == {:type => :genus, :name => 'Acromyrmex', :status => :valid,
                                                        :subfamily => 'Myrmicinae', :tribe => 'Attini'}
    end

    it 'should handle paren at one end and bracket at the other' do
      line = %{<b><i><span style='color:red'>ACROMYRMEX</span></i></b> (Myrmicinae: Attini]}
      Bolton::GenusCatalogParser.parse(line).should == {:type => :genus, :name => 'Acromyrmex', :status => :valid,
                                                        :subfamily => 'Myrmicinae', :tribe => 'Attini'}
    end

    describe "unavailable names" do
      it "should recognize a nomen nudum" do
        line = %{<i><span style='color:purple'>ANCYLOGNATHUS</span></i> [<i>Nomen nudum</i>]}
        Bolton::GenusCatalogParser.parse(line).should == {:type => :genus, :name => 'Ancylognathus', :status => :unavailable}
      end

      it "should recognize an unavailable name" do
        line = %{<i><span style="color:purple">ACHANTILEPIS</span></i> [<b>unavailable name</b>]}
        Bolton::GenusCatalogParser.parse(line).should == {:type => :genus, :name => 'Achantilepis', :status => :unavailable}
      end

      it "should recognize an unavailable name with an italicized space" do
        line = %{<i><span style="color:purple">ACHANTILEPIS</span> </i>[<b>unavailable name</b>]}
        Bolton::GenusCatalogParser.parse(line).should == {:type => :genus, :name => 'Achantilepis', :status => :unavailable}
      end

      it "should handle when the bracketed remark at end has a trailing bracket in bold" do
        line = %{<i><span style="color:purple">MYRMECIUM</span></i> [<b>unavailable name]</b>}
        Bolton::GenusCatalogParser.parse(line).should == {:type => :genus, :name => 'Myrmecium', :status => :unavailable}
      end

    end
  end

  describe "subgenus" do

    it "should recognize a subgenus" do
      line = %{#<b><i><span style='color:blue'>ACANTHOMYOPS</span></i></b> [subgenus of <i>Lasius</i>]}
      Bolton::GenusCatalogParser.parse(line).should == {:type => :subgenus, :name => 'Acanthomyops', :genus => 'Lasius', :status => :valid}
    end

    it "should ignore an errant blue space" do
      line = %{#<b><i><span style="color:blue">ANOMMA</span></i></b><span style="color:blue"> </span>[subgenus of <i>Dorylus</i>]}
      Bolton::GenusCatalogParser.parse(line).should == {:type => :subgenus, :name => 'Anomma', :genus => 'Dorylus', :status => :valid}
    end

    it "should handle it when the # is in black" do
      line = %{<span style="color:black">#</span><b><i><span style="color:blue">BARONIURBANIA</span></i></b> [subgenus of <i>Lepisiota</i>]}
      Bolton::GenusCatalogParser.parse(line).should == {:type => :subgenus, :name => 'Baroniurbania', :genus => 'Lepisiota', :status => :valid}
    end

  end

  describe 'material inside brackets' do

    it 'should parse the subfamily and tribe' do
      line = %{<b><i><span style='color:red'>ACROMYRMEX</span></i></b> [Myrmicinae: Attini]}
      Bolton::GenusCatalogParser.parse(line).should == {:type => :genus, :name => 'Acromyrmex',
                                                        :subfamily => 'Myrmicinae', :tribe => 'Attini', :status => :valid}
    end

    it "should handle an extinct subfamily" do
      line = %{*<b><i><span style='color:red'>PROTAZTECA</span></i></b> [*Myrmicinae]}
      Bolton::GenusCatalogParser.parse(line).should == {:type => :genus, :name => 'Protazteca', :subfamily => 'Myrmicinae', :fossil => true, :status => :valid}
    end

    it "should handle an extinct subfamily and extinct tribe" do
      line = %{*<b><i><span style='color:red'>PROTAZTECA</span></i></b> [*Specomyrminae: *Sphecomyrmini]}
      Bolton::GenusCatalogParser.parse(line).should == {:type => :genus, :name => 'Protazteca',
                                                        :subfamily => 'Specomyrminae', :tribe => 'Sphecomyrmini', :fossil => true, :status => :valid}
    end

    #it "should handle a parenthetical note" do
      #line = %{<b><i><span style='color:red'>PROTAZTECA</span></i></b> [<i>incertae sedis</i> in Dolichoderinae (or so they say)]}
      #Bolton::GenusCatalogParser.parse(line).should ==
     #{:type => :genus, {:name => 'Protazteca', :subfamily => 'Dolichoderinae', :tribe => 'incertae_sedis', :available => true, :valid => true, :fossil => false}
    #end

    describe 'incertae sedis' do
      it "should handle an uncertain family" do
        line = %{<b><i><span style='color:red'>MYANMYRMA</span></i></b> [<i>incertae sedis</i> in Formicidae]}
        Bolton::GenusCatalogParser.parse(line).should == {:type => :genus, :name => 'Myanmyrma', :incertae_sedis_in => :family, :status => :valid}
      end

      it "should handle uncertainty in a family" do
        line = %{<b><i><span style='color:red'>PROTAZTECA</span></i></b> [<i>incertae sedis</i> in Dolichoderinae]}
        Bolton::GenusCatalogParser.parse(line).should == {:type => :genus, :name => 'Protazteca', :subfamily => 'Dolichoderinae', :incertae_sedis_in => :subfamily, :status => :valid}
      end

      it "should handle an uncertain subfamily + tribe" do
        line = %{<b><i><span style='color:red'>ELECTROPONERA</span></i></b> [<i>incertae sedis</i> in Ectatomminae: Ectatommini]}
        Bolton::GenusCatalogParser.parse(line).should == {:type => :genus, :name => 'Electroponera', :subfamily => 'Ectatomminae', :tribe => 'Ectatommini', 
                                                          :incertae_sedis_in => :tribe, :status => :valid}
      end

      it "should handle an uncertain tribe" do
        line = %{<b><i><span style='color:red'>PROPODILOBUS</span></i></b> [Myrmicinae: <i>incertae sedis</i> in Stenammini]}
        Bolton::GenusCatalogParser.parse(line).should == {:type => :genus, :name => 'Propodilobus', :subfamily => 'Myrmicinae', :tribe => 'Stenammini',
                                                          :incertae_sedis_in => :tribe, :status => :valid}
      end

      it "should handle this" do
        line = %{*<b><i><span style='color:red'>AFROMYRMA</span></i></b><span style='color:red'> </span>[<i>incertae sedis</i> in Myrmicinae]}
        Bolton::GenusCatalogParser.parse(line).should == {:type => :genus, :name => 'Afromyrma', :subfamily => 'Myrmicinae', :incertae_sedis_in => :subfamily, :fossil => true, :status => :valid}
      end

      #it "should ignore a question mark" do
        #line = %{<b><i><span style='color:red'>CANANEURETUS</span></i></b> [Aneuretinae?]}
        #Bolton::GenusCatalogParser.parse(line).should ==
          #{:type => :genus, {:name => 'Cananeuretus', :subfamily => 'Aneuretinae', :available => true, :valid => true, :fossil => false}
      #end

    end

    describe 'synonymy' do

      it "should recognize a synonym and point to its senior" do
        line = %{<span style='color:black'><i>ACALAMA</i></span> [junior synonym of <i>Gauromyrmex</i>]}
        Bolton::GenusCatalogParser.parse(line).should ==
           {:type => :genus, :name => 'Acalama', :status => :synonym, :synonym_of => 'Gauromyrmex'}
      end

      it "should handle the closing bracket being in a useless span" do
        line = %{<span style='color:black'><i>ACALAMA</i></span> [junior synonym of <i>Gauromyrmex</i><span style='font-style:normal'>]</span>}
        Bolton::GenusCatalogParser.parse(line).should ==
           {:type => :genus, :name => 'Acalama', :status => :synonym, :synonym_of => 'Gauromyrmex'}
      end

      it "should recognize an invalid name that has no color (like Claude)" do
        line = %{<i>ACIDOMYRMEX</i> [junior synonym of <i>Rhoptromyrmex</i>]}
        Bolton::GenusCatalogParser.parse(line).should ==
           {:type => :genus, :name => 'Acidomyrmex', :status => :synonym, :synonym_of => 'Rhoptromyrmex'}
      end

      it "should handle 'Junior'" do
        line = %{<i>CRYPTOPONE</i> [Junior synonym of <i>Pachycondyla</i>]}
        Bolton::GenusCatalogParser.parse(line).should ==
           {:type => :genus, :name => 'Cryptopone', :status => :synonym, :synonym_of => 'Pachycondyla'}
      end

      it "should recognize a fossil synonym with an italicized space" do
        line = %{*<i>ACROSTIGMA </i>[junior synonym of <i>Podomyrma</i>]}
        Bolton::GenusCatalogParser.parse(line).should ==
           {:type => :genus, :name => 'Acrostigma', :status => :synonym, :synonym_of => 'Podomyrma', 
            :fossil => true}
      end

      it "should recognize a fossil synonym of a fossil" do
        line = %{*<i>AMEGHINOIA </i>[junior synonym of *<i>Archimyrmex</i>]}
        Bolton::GenusCatalogParser.parse(line).should ==
           {:type => :genus, :name => 'Ameghinoia', :status => :synonym, :synonym_of => 'Archimyrmex', 
            :fossil => true}
      end

      it "should handle a misspelling of 'synonym'" do
        line = %{<i>CREIGHTONIDRIS</i> [junior syonym of <i>Basiceros</i>]}
        Bolton::GenusCatalogParser.parse(line).should ==
           {:type => :genus, :name => 'Creightonidris', :status => :synonym, :synonym_of => 'Basiceros'}
      end

    end

    describe 'homonymy' do

      it "should recognize a homonym and point to its senior" do
        line = %{<i>ACAMATUS</i><span style='font-style:normal'> [junior homonym, see </span><i>Neivamyrmex</i><span style='font-style:normal'>]</span>}
        Bolton::GenusCatalogParser.parse(line).should ==
           {:type => :genus, :name => 'Acamatus', :status => :homonym, :homonym_of => 'Neivamyrmex'}
      end

      it "should handle it without spans" do
        line = %{<i>ACAMATUS</i> [junior homonym, see <i>Neivamyrmex</i>]}
        Bolton::GenusCatalogParser.parse(line).should ==
           {:type => :genus, :name => 'Acamatus', :status => :homonym, :homonym_of => 'Neivamyrmex'}
      end

      it "should handle fossil homonyms" do
        line = %{*<i>HETEROMYRMEX</i> [junior homonym, see *<i>Zhangidris</i>]}
        Bolton::GenusCatalogParser.parse(line).should ==
           {:type => :genus, :name => 'Heteromyrmex', :status => :homonym, :homonym_of => 'Zhangidris', :fossil => true}
      end

    end

  #end
  end

  describe "genus detail line" do

    it "should recognize anything beginning with tags and non-word characters, followed by a capitalized word" do
      line = %{<i style='mso-bidi-font-style:normal'>Acamatus</i> Emery, 1894c: 181 [as subgenus
of <i style='mso-bidi-font-style:normal'>Eciton</i>]. Type-species: <i
style='mso-bidi-font-style:normal'>Eciton (Acamatus) schmitti</i> (junior
synonym of <i style='mso-bidi-font-style:normal'>Labidus nigrescens</i>), by
subsequent designation of Ashmead, 1906: 24; Wheeler, W.M. 1911f: 157. [Junior
homonym of <i style='mso-bidi-font-style:normal'>Acamatus </i>Schoenherr, 1833:
20 (Coleoptera).]
        }
      Bolton::GenusCatalogParser.parse(line).should == {:type => :genus_detail_line}
    end
    
    it "should recognize anything totally inside brackets" do
      line = %{<span style="mso-spacerun: yes">  </span>[All subgenera were given as provisional junior synonyms of <i style="mso-bidi-font-style:normal">Camponotus</i> by Brown, 1973b: 179-185. The list was repeated in Hölldobler & Wilson, 1990: 18 with all subgenera listed as junior synonyms. They reverted to subgeneric status in Bolton, 1994: 50; see under individual entries. The entry of <i style="mso-bidi-font-style:normal">Myrmophyma</i> and <i style="mso-bidi-font-style:normal">Thlipsepinotus</i> under the synonymy of <i style="mso-bidi-font-style:normal">Camponotus</i> by Taylor & Brown, D.R. 1985: 109, is not accepted as confirmation as not all taxa were included.]}
      Bolton::GenusCatalogParser.parse(line).should == {:type => :genus_detail_line}
    end

    it "should handle space at the beginning" do
      line = %{<span style="mso-spacerun: yes"> </span><i>Cryptopone</i> junior synonym of <i>Pachycondyla</i>: Mackay & Mackay, 2010: 3.}
      Bolton::GenusCatalogParser.parse(line).should == {:type => :genus_detail_line}
    end

  end

  it "should handle collective group names" do
    line = %{*<i><span style="color:green">FORMICITES</span></i> [collective group name]}
    Bolton::GenusCatalogParser.parse(line).should == {:type => :collective_group_name}
  end
end
