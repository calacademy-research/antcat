require 'spec_helper'

describe Bolton::SubfamilyCatalog do
  before do
    @subfamily_catalog = Bolton::SubfamilyCatalog.new
  end

  describe "Headers" do

    it "should recognize a subfamily centered header" do
      @subfamily_catalog.parse(%{
  <b><span lang=EN-GB>SUBFAMILY <span style='color:red'>ANEURETINAE</span><o:p></o:p></span></b>
      }).should == {:type => :subfamily_centered_header}
    end

    it "should recognize another form of subfamily centered header" do
      @subfamily_catalog.parse(%{
  <b><span lang="EN-GB" style="color:black">SUBFAMILY</span><span lang="EN-GB"> <span style="color:red">MARTIALINAE</span><p></p></span></b>
      }).should == {:type => :subfamily_centered_header}
    end

    it "should recognize a subfamily header" do
      @subfamily_catalog.parse(%{
  <b><span lang=EN-GB>Subfamily <span style='color:red'>MYRMICINAE</span> <o:p></o:p></span></b>
      }).should == {:type => :subfamily_header, :name => 'Myrmicinae'}
    end

    it "should recognize an extinct subfamily header" do
      @subfamily_catalog.parse(%{
  <b><span lang=EN-GB>Subfamily *<span style='color:red'>ARMANIINAE</span> <o:p></o:p></span></b></p>
      }).should == {:type => :subfamily_header, :name => 'Armaniinae', :fossil => true}
    end

    describe "Tribe header" do

      it "should be recognized" do
        @subfamily_catalog.parse(%{
    <b><span lang=EN-GB>Tribe <span style='color:red'>MYRMECIINI</span><o:p></o:p></span></b></p>
        }).should == {:type => :tribe_header, :name => 'Myrmeciini'}
      end

      it "should be recognized when it's extinct" do
        @subfamily_catalog.parse(%{
    <b><span lang=EN-GB>Tribe *<span style='color:red'>MIOMYRMECINI</span><o:p></o:p></span></b>
        }).should == {:type => :tribe_header, :name => 'Miomyrmecini', :fossil => true}
      end

      it "should be recognized when the asterisk is in a different place" do
        @subfamily_catalog.parse(%{
    <b><span lang=EN-GB>Tribe</span></b><span lang=EN-GB> *<b style='mso-bidi-font-weight:normal'><span style='color:red'>PITYOMYRMECINI</span></b></span>
        }).should == {:type => :tribe_header, :name => 'Pityomyrmecini', :fossil => true}
      end

    end

    describe "Genera header" do

      it "should be recognized" do
        @subfamily_catalog.parse(%{
    <b><span lang=EN-GB>Genera of <span style='color:red'>Aneuretini</span><o:p></o:p></span></b>
        }).should == {:type => :genera_header}
      end

      it "should be recognized when there's only one genus" do
        @subfamily_catalog.parse(%{
    <b><span lang=EN-GB>Genus of <span style='color:red'>Dolichoderini</span><o:p></o:p></span></b>
        }).should == {:type => :genera_header}
      end

    end

    describe "Genera incertae sedis header" do

      it "should be recognized" do
        @subfamily_catalog.parse(%{
<b><span lang=EN-GB>Genera <i>incertae sedis</i> in <span style='color:red'>ANEURETINAE</span><o:p></o:p></span></b>
        }).should == {:type => :genera_incertae_sedis_header}
      end

      it "should be recognized when there's only one genus" do
        @subfamily_catalog.parse(%{
    <b><span lang=EN-GB>Genus <i>incertae sedis</i> in <span style='color:red'>ANEURETINAE</span><o:p></o:p></span></b>
        }).should == {:type => :genera_incertae_sedis_header}
      end

    end

  end

  describe "Lists" do
    describe "Tribes list" do

      it "should recognize a tribes list" do
        @subfamily_catalog.parse(%{
    <b><span lang=EN-GB>Tribes of Aneuretinae</span></b><span lang=EN-GB>: Aneuretini, *Pityomyrmecini.</span>
        }).should == {:type => :tribes_list, :tribes => [['Aneuretini', nil], ['Pityomyrmecini', true]]}
      end

      it "should recognize an extinct tribes list" do
        @subfamily_catalog.parse(%{
    <b><span lang=EN-GB>Tribes (extinct) of Aneuretinae</span></b><span lang=EN-GB>: Aneuretini, *Pityomyrmecini.</span>
        }).should == {:type => :tribes_list, :tribes => [['Aneuretini', nil], ['Pityomyrmecini', true]]}
      end

      it "should recognize an extant tribes list" do
        @subfamily_catalog.parse(%{
    <b><span lang=EN-GB>Tribes (extant) of Aneuretinae</span></b><span lang=EN-GB>: Aneuretini, *Pityomyrmecini.</span>
        }).should == {:type => :tribes_list, :tribes => [['Aneuretini', nil], ['Pityomyrmecini', true]]}
      end

      it "should recognize an tribes list with one tribe" do
        @subfamily_catalog.parse(%{
    <b><span lang=EN-GB>Tribe of Aneuretinae</span></b><span lang=EN-GB>: Aneuretini.</span>
        }).should == {:type => :tribes_list, :tribes => [['Aneuretini', nil]]}
      end
      
      it "should recognize an extinct tribes incertae sedis list" do
        @subfamily_catalog.parse(%{
  <b><span lang=EN-GB>Tribes (extinct) <i>incertae sedis</i> in Dolichoderinae</span></b><span lang=EN-GB>: *Miomyrmecini, *Zherichiniini.</span>
        }).should == {:type => :tribes_list, :tribes => [['Miomyrmecini', true], ['Zherichiniini', true]], :incertae_sedis => true}
      end

      it "should recognize a tribes list that doesn't start out bold" do
        @subfamily_catalog.parse(%{
<span lang=EN-GB>Tribes of Myrmeciinae: Myrmeciini, Prionomyrmecini.</span>
        }).should == {:type => :tribes_list, :tribes => [['Myrmeciini', nil], ['Prionomyrmecini', nil]]}
      end

      it "should be recognized when the list doesn't include the subfamily name" do
        @subfamily_catalog.parse(%{
<b><span lang=EN-GB>Tribe</span></b><span lang=EN-GB>: Pseudomyrmecini.</span>
        }).should == {:type => :tribes_list, :tribes => [['Pseudomyrmecini', nil]]}
      end

    end

    describe "Genera lists" do

      it "should recognize a genera list" do
        @subfamily_catalog.parse(%{
<b><span lang=EN-GB>Genera of Aneuretinae</span></b><span lang=EN-GB>: <i>Burmomyrma, *Cananeuretus</i>. </span>
        }).should == {:type => :genera_list, :genera => [['Burmomyrma', nil], ['Cananeuretus', true]]}
      end

      it "should be recognized with colon inside the first span" do
        @subfamily_catalog.parse(%{
<b><span lang=EN-GB>Genera of Leptomyrmecini: </span></b><i><span lang=EN-GB>Anillidris</i>.
        }).should == {:type => :genera_list, :genera => [['Anillidris', nil]]}
      end

      it "should recognize a genera list without a period" do
        @subfamily_catalog.parse(%{
<b><span lang=EN-GB>Genus</span></b><span lang=EN-GB>: <i>Notostigma</i></span>
        }).should == {:type => :genera_list, :genera => [['Notostigma', nil]]}
      end

      it "should recognize a genera list with just one extinct genus" do
        @subfamily_catalog.parse(%{
    <b><span lang=EN-GB>Genus</span></b><span lang=EN-GB>: *<i>Pityomyrmex</i>.</span>
        }).should == {:type => :genera_list, :genera => [['Pityomyrmex', true]]}
      end

      it "should be recognized with a black parent taxon" do
        @subfamily_catalog.parse(%{
<b><span lang=EN-GB>Genera of <span style='color:black'>Bothriomyrmecini</span></span></b><span lang=EN-GB>: <i>Arnoldius</i>.</span>
        }).should == {:type => :genera_list, :genera => [['Arnoldius', nil]]}
      end

      it "should be recognized with the period well after the end of the list" do
        @subfamily_catalog.parse(%{
<b><span lang=EN-GB>Genus</span></b><span lang=EN-GB>: *<i>Miomyrmex</i> (see under: Genera <i>incertae sedis</i> in Dolichoderinae, below).</span>
        }).should == {:type => :genera_list, :genera => [['Miomyrmex', true]]}
      end

      it "should be recognized with the period well after the end of the list" do
        @subfamily_catalog.parse(%{
<b><span lang=EN-GB>Genus</span></b><span lang=EN-GB> of Aenictogitonini: <i>Aenictogiton</i>.</span></p>
        }).should == {:type => :genera_list, :genera => [['Aenictogiton', nil]]}
      end

    end

    describe "Genera incertae sedis lists" do

      it "should recognize a genera incertae sedis list" do
        @subfamily_catalog.parse(%{
    <b><span lang=EN-GB>Genera <i>incertae sedis</i> in Aneuretinae</span></b><span lang=EN-GB>: <i>Burmomyrma, *Cananeuretus</i>. </span>
        }).should == {:type => :genera_list, :incertae_sedis => true, :genera => [['Burmomyrma', nil], ['Cananeuretus', true]]}
      end

      it "should recognize an extinct genera incertae sedis list" do
        @subfamily_catalog.parse(%{
    <b><span lang=EN-GB>Genera (extinct) <i>incertae sedis</i> in Aneuretinae</span></b><span lang=EN-GB>: *<i>Burmomyrma, *Cananeuretus</i>. </span>
        }).should == {:type => :genera_list, :incertae_sedis => true, :genera => [['Burmomyrma', true], ['Cananeuretus', true]]}
      end

      it "should recognize an extinct genera incertae sedis list" do
        @subfamily_catalog.parse(%{
<b><span lang=EN-GB>Genus <i>incertae sedis</i> in Gesomyrmecini</span></b><span lang=EN-GB>: *<i>Prodimorphomyrmex</i>.</span></p>
        }).should == {:type => :genera_list, :incertae_sedis => true, :genera => [['Prodimorphomyrmex', true]]}
      end

      it "should recognize an extant genera incertae sedis list" do
        @subfamily_catalog.parse(%{
    <b><span lang=EN-GB>Genera (extant) <i>incertae sedis</i> in Aneuretinae</span></b><span lang=EN-GB>: <i>Burmomyrma, Cananeuretus</i>. </span>
        }).should == {:type => :genera_list, :incertae_sedis => true, :genera => [['Burmomyrma', nil], ['Cananeuretus', nil]]}
      end

      it "should recognize a Hong 2002 genera incertae sedis list" do
        @subfamily_catalog.parse(%{
  <b><span lang=EN-GB>Hong (2002) genera (extinct) <i>incertae sedis</i> in Formicinae</span></b><span lang=EN-GB>: *<i>Curtipalpulus.</i> (unresolved junior homonym).</span></p>
        }).should == {:type => :genera_list, :incertae_sedis => true, :genera => [['Curtipalpulus', true]]}
      end

      it "should recognize a Hong 2002 genera incertae sedis list" do
        @subfamily_catalog.parse(%{
<b><span lang="EN-GB">Genera (extinct<i>) incertae sedis</i> in Myrmeciinae</span></b><span lang="EN-GB">: *<i>Archimyrmex</i>.</span>
        }).should == {:type => :genera_list, :incertae_sedis => true, :genera => [['Archimyrmex', true]]}
      end

      it "should be recognized when the incertae sedis part is a bit different" do
        @subfamily_catalog.parse(%{
<b><span lang=EN-GB>Genus (extinct) <i>incertae sedis </i>in Ectatommini</span></b><span lang=EN-GB>: *<i>Electroponera</i>.</span>
        }).should == {:type => :genera_list, :genera => [['Electroponera', true]], :incertae_sedis => true}
      end

      it "should be recognized when the incertae sedis part is a bit different" do
        @subfamily_catalog.parse(%{
<b><span lang=EN-GB>Genus (extinct) <i>incertae sedis </i>in Ectatommini</span></b><span lang=EN-GB>: *<i>Electroponera</i>.</span>
        }).should == {:type => :genera_list, :genera => [['Electroponera', true]], :incertae_sedis => true}
      end

      it "should be recognized when the incertae sedis part is a bit different" do
        @subfamily_catalog.parse(%{
<b><span lang=EN-GB>Genus<i style='mso-bidi-font-style:normal'> incertae sedis</i> in Heteroponerini</span></b><span lang=EN-GB>:<i> Aulacopone</i>.</span></p>
        }).should == {:type => :genera_list, :genera => [['Aulacopone', nil]], :incertae_sedis => true}
      end

      it "should be recognized when the astierisk is italicized" do
        @subfamily_catalog.parse(%{
<b><span lang=EN-GB>Genus <i>incertae sedis</i></span></b><span lang=EN-GB> in Stenammini: <i>*Ilemomyrmex</i>.</span>
        }).should == {:type => :genera_list, :genera => [['Ilemomyrmex', true]], :incertae_sedis => true}
      end

    end

    it "should recognize a collective group name list" do
      @subfamily_catalog.parse(%{
  <b><span lang=EN-GB>Collective group name in Myrmeciinae</span></b><span lang=EN-GB>: *<i>Myrmeciites</i>.</span></p>
      }).should == {:type => :collective_group_name_list, :names => [['Myrmeciites', true]]}
    end

  end

end
