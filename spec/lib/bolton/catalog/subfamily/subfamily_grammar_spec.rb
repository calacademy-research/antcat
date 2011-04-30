require 'spec_helper'

describe Bolton::Catalog::Subfamily::Importer do
  before do
    @importer = Bolton::Catalog::Subfamily::Importer.new
  end

  describe "Headers" do

    it "should recognize a subfamily centered header" do
      @importer.parse(%{
  <b><span lang=EN-GB>SUBFAMILY <span style='color:red'>ANEURETINAE</span><o:p></o:p></span></b>
      }).should == {:type => :subfamily_centered_header}
    end

    it "should recognize the subfamily centered header for an extinct subfamily" do
      @importer.parse(%{
  <b><span lang=EN-GB>SUBFAMILY *<span style='color:red'>ARMANIINAE</span><o:p></o:p></span></b>
      }).should == {:type => :subfamily_centered_header}
    end

    it "should recognize the subfamily header for an extinct subfamily" do
      @importer.parse(%{
  <b><span lang=EN-GB>Subfamily *<span style='color:red'>ARMANIINAE</span> <o:p></o:p></span></b>
      }).should == {:type => :subfamily_header, :name => 'Armaniinae', :fossil => true}
    end

    it "should recognize another form of subfamily centered header" do
      @importer.parse(%{
  <b><span lang="EN-GB" style="color:black">SUBFAMILY</span><span lang="EN-GB"> <span style="color:red">MARTIALINAE</span><p></p></span></b>
      }).should == {:type => :subfamily_centered_header}
    end

    it "should recognize a subfamily header" do
      @importer.parse(%{
  <b><span lang=EN-GB>Subfamily <span style='color:red'>MYRMICINAE</span> <o:p></o:p></span></b>
      }).should == {:type => :subfamily_header, :name => 'Myrmicinae'}
    end

    it "should recognize an extinct subfamily header" do
      @importer.parse(%{
  <b><span lang=EN-GB>Subfamily *<span style='color:red'>ARMANIINAE</span> <o:p></o:p></span></b>
      }).should == {:type => :subfamily_header, :name => 'Armaniinae', :fossil => true}
    end

    describe "Tribe header" do

      it "should be recognized" do
        @importer.parse(%{
    <b><span lang=EN-GB>Tribe <span style='color:red'>MYRMECIINI</span><o:p></o:p></span></b>
        }).should == {:type => :tribe_header, :name => 'Myrmeciini'}
      end

      it "should be recognized when it's extinct" do
        @importer.parse(%{
    <b><span lang=EN-GB>Tribe *<span style='color:red'>MIOMYRMECINI</span><o:p></o:p></span></b>
        }).should == {:type => :tribe_header, :name => 'Miomyrmecini', :fossil => true}
      end

      it "should be recognized when the asterisk is in a different place" do
        @importer.parse(%{
    <b><span lang=EN-GB>Tribe</span></b><span lang=EN-GB> *<b style='mso-bidi-font-weight:normal'><span style='color:red'>PITYOMYRMECINI</span></b></span>
        }).should == {:type => :tribe_header, :name => 'Pityomyrmecini', :fossil => true}
      end

    end

    describe "Genera header" do

      it "should be recognized" do
        @importer.parse(%{
    <b><span lang=EN-GB>Genera of <span style='color:red'>Aneuretini</span><o:p></o:p></span></b>
        }).should == {:type => :genera_header}
      end

      it "should be recognized when there's only one genus" do
        @importer.parse(%{
    <b><span lang=EN-GB>Genus of <span style='color:red'>Dolichoderini</span><o:p></o:p></span></b>
        }).should == {:type => :genera_header}
      end

    end

    describe "Genera incertae sedis header" do

      it "should be recognized" do
        @importer.parse(%{
<b><span lang=EN-GB>Genera <i>incertae sedis</i> in <span style='color:red'>ANEURETINAE</span><o:p></o:p></span></b>
        }).should == {:type => :genera_incertae_sedis_header}
      end

      it "should be recognized when there's only one genus" do
        @importer.parse(%{
    <b><span lang=EN-GB>Genus <i>incertae sedis</i> in <span style='color:red'>ANEURETINAE</span><o:p></o:p></span></b>
        }).should == {:type => :genera_incertae_sedis_header}
      end

      it "should be recognized when extinct" do
        @importer.parse(%{
<b><span lang="EN-GB">Genera (extinct) <i>incertae sedis</i> in <span style="color:red">DOLICHODERINAE<p></p></span></span></b>
        }).should == {:type => :genera_incertae_sedis_header}
      end

    end

  end

  describe "Lists" do
    describe "Tribes list" do

      it "should recognize a tribes list" do
        @importer.parse(%{
    <b><span lang=EN-GB>Tribes of Aneuretinae</span></b><span lang=EN-GB>: Aneuretini, *Pityomyrmecini.</span>
        }).should == {:type => :tribes_list, :tribes => [{:name => 'Aneuretini'}, {:name => 'Pityomyrmecini', :fossil => true}]}
      end

      it "should recognize an extinct tribes list" do
        @importer.parse(%{
    <b><span lang=EN-GB>Tribes (extinct) of Aneuretinae</span></b><span lang=EN-GB>: Aneuretini, *Pityomyrmecini.</span>
        }).should == {:type => :tribes_list, :tribes => [{:name => 'Aneuretini'}, {:name => 'Pityomyrmecini', :fossil => true}]}
      end

      it "should recognize an extant tribes list" do
        @importer.parse(%{
    <b><span lang=EN-GB>Tribes (extant) of Aneuretinae</span></b><span lang=EN-GB>: Aneuretini, *Pityomyrmecini.</span>
        }).should == {:type => :tribes_list, :tribes => [{:name => 'Aneuretini'}, {:name => 'Pityomyrmecini', :fossil => true}]}
      end

      it "should recognize an tribes list with one tribe" do
        @importer.parse(%{
    <b><span lang=EN-GB>Tribe of Aneuretinae</span></b><span lang=EN-GB>: Aneuretini.</span>
        }).should == {:type => :tribes_list, :tribes => [{:name => 'Aneuretini'}]}
      end
      
      it "should recognize an extinct tribes incertae sedis list" do
        @importer.parse(%{
  <b><span lang=EN-GB>Tribes (extinct) <i>incertae sedis</i> in Dolichoderinae</span></b><span lang=EN-GB>: *Miomyrmecini, *Zherichiniini.</span>
        }).should == {:type => :tribes_list, :tribes => [{:name => 'Miomyrmecini', :fossil => true}, {:name => 'Zherichiniini', :fossil => true}], :incertae_sedis => true}
      end

      it "should recognize a tribes list that doesn't start out bold" do
        @importer.parse(%{
<span lang=EN-GB>Tribes of Myrmeciinae: Myrmeciini, Prionomyrmecini.</span>
        }).should == {:type => :tribes_list, :tribes => [{:name => 'Myrmeciini'}, {:name => 'Prionomyrmecini'}]}
      end

      it "should be recognized when the list doesn't include the subfamily name" do
        @importer.parse(%{
<b><span lang=EN-GB>Tribe</span></b><span lang=EN-GB>: Pseudomyrmecini.</span>
        }).should == {:type => :tribes_list, :tribes => [{:name => 'Pseudomyrmecini'}]}
      end

      it "should be recognized with an extinct subfamily" do
        @importer.parse(%{
<b><span lang=EN-GB>Tribes of *Sphecomyrminae</span></b><span lang=EN-GB>: *Haidomyrmecini.</span>
        }).should == {:type => :tribes_list, :tribes => [{:name => 'Haidomyrmecini', :fossil => true}]}
      end

    end

    describe "Genera lists" do

      it "should recognize a genera list" do
        @importer.parse(%{
<b><span lang=EN-GB>Genera of Aneuretinae</span></b><span lang=EN-GB>: <i>Burmomyrma, *Cananeuretus</i>. </span>
        }).should == {:type => :genera_list, :genera => [{:name => 'Burmomyrma'}, {:name => 'Cananeuretus', :fossil => true}]}
      end

      it "should be recognized with colon inside the first span" do
        @importer.parse(%{
<b><span lang=EN-GB>Genera of Leptomyrmecini: </span></b><i><span lang=EN-GB>Anillidris</i>.
        }).should == {:type => :genera_list, :genera => [{:name => 'Anillidris'}]}
      end

      it "should recognize a genera list without a period" do
        @importer.parse(%{
<b><span lang=EN-GB>Genus</span></b><span lang=EN-GB>: <i>Notostigma</i></span>
        }).should == {:type => :genera_list, :genera => [{:name => 'Notostigma'}]}
      end

      it "should recognize a genera list with just one extinct genus" do
        @importer.parse(%{
    <b><span lang=EN-GB>Genus</span></b><span lang=EN-GB>: *<i>Pityomyrmex</i>.</span>
        }).should == {:type => :genera_list, :genera => [{:name => 'Pityomyrmex', :fossil => true}]}
      end

      it "should be recognized with a black parent taxon" do
        @importer.parse(%{
<b><span lang=EN-GB>Genera of <span style='color:black'>Bothriomyrmecini</span></span></b><span lang=EN-GB>: <i>Arnoldius</i>.</span>
        }).should == {:type => :genera_list, :genera => [{:name => 'Arnoldius'}]}
      end

      it "should be recognized with the period well after the end of the list" do
        @importer.parse(%{
<b><span lang=EN-GB>Genus</span></b><span lang=EN-GB>: *<i>Miomyrmex</i> (see under: Genera <i>incertae sedis</i> in Dolichoderinae, below).</span>
        }).should == {:type => :genera_list, :genera => [{:name => 'Miomyrmex', :fossil => true}]}
      end

      it "should be recognized with the period well after the end of the list" do
        @importer.parse(%{
<b><span lang=EN-GB>Genus</span></b><span lang=EN-GB> of Aenictogitonini: <i>Aenictogiton</i>.</span>
        }).should == {:type => :genera_list, :genera => [{:name => 'Aenictogiton'}]}
      end

      it "should be recognized for an extinct subfamily" do
        @importer.parse(%{
<b><span lang=EN-GB>Genera (extinct) of *Armaniini</span></b><span lang=EN-GB>: *<i>Archaeopone</i>.</span>
        }).should == {:type => :genera_list, :genera => [{:name => 'Archaeopone', :fossil => true}]}
      end

      it "should be recognized for an extinct subfamily" do
        @importer.parse(%{
<b><span lang=EN-GB>Genus (extinct) of *Brownimeciini</span></b><span lang=EN-GB>: *<i>Brownimecia</i></span>
        }).should == {:type => :genera_list, :genera => [{:name => 'Brownimecia', :fossil => true}]}
      end

    end

    describe "Genera incertae sedis lists" do

      it "should recognize a genera incertae sedis list" do
        @importer.parse(%{
    <b><span lang=EN-GB>Genera <i>incertae sedis</i> in Aneuretinae</span></b><span lang=EN-GB>: <i>Burmomyrma, *Cananeuretus</i>. </span>
        }).should == {:type => :genera_list, :incertae_sedis => true, :genera => [{:name => 'Burmomyrma'}, {:name => 'Cananeuretus', :fossil => true}]}
      end

      it "should recognize an extinct genera incertae sedis list" do
        @importer.parse(%{
    <b><span lang=EN-GB>Genera (extinct) <i>incertae sedis</i> in Aneuretinae</span></b><span lang=EN-GB>: *<i>Burmomyrma, *Cananeuretus</i>. </span>
        }).should == {:type => :genera_list, :incertae_sedis => true, :genera => [{:name => 'Burmomyrma', :fossil => true}, {:name => 'Cananeuretus', :fossil => true}]}
      end

      it "should recognize an extinct genera incertae sedis list" do
        @importer.parse(%{
<b><span lang=EN-GB>Genus <i>incertae sedis</i> in Gesomyrmecini</span></b><span lang=EN-GB>: *<i>Prodimorphomyrmex</i>.</span>
        }).should == {:type => :genera_list, :incertae_sedis => true, :genera => [{:name => 'Prodimorphomyrmex', :fossil => true}]}
      end

      it "should recognize an extant genera incertae sedis list" do
        @importer.parse(%{
    <b><span lang=EN-GB>Genera (extant) <i>incertae sedis</i> in Aneuretinae</span></b><span lang=EN-GB>: <i>Burmomyrma, Cananeuretus</i>. </span>
        }).should == {:type => :genera_list, :incertae_sedis => true, :genera => [{:name => 'Burmomyrma'}, {:name => 'Cananeuretus'}]}
      end

      it "should recognize a Hong 2002 genera incertae sedis list, and handle an unresolved junior homonym in it" do
        @importer.parse(%{
  <b><span lang=EN-GB>Hong (2002) genera (extinct) <i>incertae sedis</i> in Formicinae</span></b><span lang=EN-GB>: *<i>Curtipalpulus</i> (unresolved junior homonym).</span>
        }).should == {:type => :genera_list, :incertae_sedis => true, :genera => [{:name => 'Curtipalpulus', :fossil => true, :status => 'unresolved homonym'}]}
      end

      it "should recognize a list with misplaced italic tag" do
        @importer.parse(%{
<b><span lang="EN-GB">Genera (extinct<i>) incertae sedis</i> in Myrmeciinae</span></b><span lang="EN-GB">: *<i>Archimyrmex</i>.</span>
        }).should == {:type => :genera_list, :incertae_sedis => true, :genera => [{:name => 'Archimyrmex', :fossil => true}]}
      end

      it "should be recognized when the incertae sedis part is a bit different" do
        @importer.parse(%{
<b><span lang=EN-GB>Genus (extinct) <i>incertae sedis </i>in Ectatommini</span></b><span lang=EN-GB>: *<i>Electroponera</i>.</span>
        }).should == {:type => :genera_list, :genera => [{:name => 'Electroponera', :fossil => true}], :incertae_sedis => true}
      end

      it "should be recognized when the incertae sedis part is a bit different" do
        @importer.parse(%{
<b><span lang=EN-GB>Genus (extinct) <i>incertae sedis </i>in Ectatommini</span></b><span lang=EN-GB>: *<i>Electroponera</i>.</span>
        }).should == {:type => :genera_list, :genera => [{:name => 'Electroponera', :fossil => true}], :incertae_sedis => true}
      end

      it "should be recognized when the incertae sedis part is a bit different" do
        @importer.parse(%{
<b><span lang=EN-GB>Genus<i style='mso-bidi-font-style:normal'> incertae sedis</i> in Heteroponerini</span></b><span lang=EN-GB>:<i> Aulacopone</i>.</span>
        }).should == {:type => :genera_list, :genera => [{:name => 'Aulacopone'}], :incertae_sedis => true}
      end

      it "should be recognized when the asterisk is italicized" do
        @importer.parse(%{
<b><span lang=EN-GB>Genus <i>incertae sedis</i></span></b><span lang=EN-GB> in Stenammini: <i>*Ilemomyrmex</i>.</span>
        }).should == {:type => :genera_list, :genera => [{:name => 'Ilemomyrmex', :fossil => true}], :incertae_sedis => true}
      end

      it "for a supersubfamily should be recognized" do
        @importer.parse(%{
<b><span lang=EN-GB>Genera (extinct) <i>incertae sedis</i> in poneroid subfamilies</span></b><span lang=EN-GB>: *<i>Cretopone</i>, *<i>Petropone</i>.</span>
        }).should == {:type => :genera_list, :genera => [{:name => 'Cretopone', :fossil => true}, {:name => 'Petropone', :fossil => true}], :incertae_sedis => true}
      end

      it "for a supersubfamily with a different name should be recognized" do
        @importer.parse(%{
<b><span lang="EN-GB">Genera (extinct) <i>incertae sedis</i> in poneromorph subfamilies</span></b><span lang="EN-GB">: *<i>Cretopone</i>, *<i>Petropone</i>.</span>
        }).should == {:type => :genera_list, :genera => [{:name => 'Cretopone', :fossil => true}, {:name => 'Petropone', :fossil => true}], :incertae_sedis => true}
      end

    end

    it "should recognize a collective group name list" do
      @importer.parse(%{
  <b><span lang=EN-GB>Collective group name in Myrmeciinae</span></b><span lang=EN-GB>: *<i>Myrmeciites</i>.</span>
      }).should == {:type => :collective_group_name_list, :names => [{:name => 'Myrmeciites', :fossil => true}]}
    end

    describe "Parsing a group of list names" do

      it "should recognize one name" do
        Bolton::Catalog::Subfamily::Grammar.parse("*<i>Myrmeciites</i>.</span>", :root => :list_names).value.should == [{:name => 'Myrmeciites', :fossil => true}]
      end

      it "should recognize more than one name" do
        Bolton::Catalog::Subfamily::Grammar.parse(%{*<i>Myrmeciites</i>, <i>Petropone</i>.</span>}, :root => :list_names).value.should ==
          [{:name => 'Myrmeciites', :fossil => true}, {:name => 'Petropone'}]
      end

    end

    describe "Collective group name header" do

      it "should be recognized" do
        @importer.parse(%{
<b><span lang=EN-GB>Collective group name in <span style='color:red'>MYRMICINAE</span><o:p></o:p></span></b>
        }).should == {:type => :collective_group_name_header}
      end

    end
  end
end
