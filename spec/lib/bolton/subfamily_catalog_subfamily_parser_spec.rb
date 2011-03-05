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

    #it "should recognize an extinct genera incertae sedis header" do
      #@subfamily_catalog.parse(%{
  #<b><span lang=EN-GB>Genera (extinct) <i>incertae sedis</i> in Aneuretinae</span></b><span lang=EN-GB>: *<i>Burmomyrma, *Cananeuretus</i>. </span>
      #}).should == {:type => :extinct_genera_incertae_sedis_in_subfamily_list, :genera => ['Burmomyrma', 'Cananeuretus']}
    #end

    #it "should recognize a genera incertae sedis header" do
      #@subfamily_catalog.parse(%{
  #<b><span lang=EN-GB>Genera (extinct) <i>incertae sedis</i> in Aneuretinae</span></b><span lang=EN-GB>: *<i>Burmomyrma, *Cananeuretus</i>. </span>
      #}).should == {:type => :extinct_genera_incertae_sedis_in_subfamily_list, :genera => ['Burmomyrma', 'Cananeuretus']}
    #end

    #it "should recognize a Hong 2002 genera incertae sedis header" do
      #@subfamily_catalog.parse(%{
  #<b><span lang=EN-GB>Genera (extinct) <i>incertae sedis</i> in Aneuretinae</span></b><span lang=EN-GB>: *<i>Burmomyrma, *Cananeuretus</i>. </span>
      #}).should == {:type => :extinct_genera_incertae_sedis_in_subfamily_list, :genera => ['Burmomyrma', 'Cananeuretus']}
    #end

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

    end

    describe "Genus incertae sedis lists" do

      it "should recognize a genera incertae sedis list" do
        @subfamily_catalog.parse(%{
    <b><span lang=EN-GB>Genera <i>incertae sedis</i> in Aneuretinae</span></b><span lang=EN-GB>: <i>Burmomyrma, *Cananeuretus</i>. </span>
        }).should == {:type => :genera_incertae_sedis_list, :genera => [['Burmomyrma', nil], ['Cananeuretus', true]]}
      end

      it "should recognize an extinct genera incertae sedis list" do
        @subfamily_catalog.parse(%{
    <b><span lang=EN-GB>Genera (extinct) <i>incertae sedis</i> in Aneuretinae</span></b><span lang=EN-GB>: *<i>Burmomyrma, *Cananeuretus</i>. </span>
        }).should == {:type => :genera_incertae_sedis_list, :genera => [['Burmomyrma', true], ['Cananeuretus', true]]}
      end

      it "should recognize an extant genera incertae sedis list" do
        @subfamily_catalog.parse(%{
    <b><span lang=EN-GB>Genera (extant) <i>incertae sedis</i> in Aneuretinae</span></b><span lang=EN-GB>: <i>Burmomyrma, Cananeuretus</i>. </span>
        }).should == {:type => :genera_incertae_sedis_list, :genera => [['Burmomyrma', nil], ['Cananeuretus', nil]]}
      end

      it "should recognize a Hong 2002 genera incertae sedis list" do
        @subfamily_catalog.parse(%{
  <b><span lang=EN-GB>Hong (2002) genera (extinct) <i>incertae sedis</i> in Formicinae</span></b><span lang=EN-GB>: *<i>Curtipalpulus.</i> (unresolved junior homonym).</span></p>
        }).should == {:type => :genera_incertae_sedis_list, :genera => [['Curtipalpulus', true]]}
      end

    end

    #it "should recognize a collective group name list" do
      #@subfamily_catalog.parse(%{
  #<b><span lang=EN-GB>Genera (extinct) <i>incertae sedis</i> in Aneuretinae</span></b><span lang=EN-GB>: *<i>Burmomyrma, *Cananeuretus</i>. </span>
      #}).should == {:type => :extinct_genera_incertae_sedis_in_subfamily_list, :genera => ['Burmomyrma', 'Cananeuretus']}
    #end

  end

  #it "should recognize a collective group name" do
    #@subfamily_catalog.parse(%{
#<b><span lang=EN-GB>Genera (extinct) <i>incertae sedis</i> in Aneuretinae</span></b><span lang=EN-GB>: *<i>Burmomyrma, *Cananeuretus</i>. </span>
    #}).should == {:type => :extinct_genera_incertae_sedis_in_subfamily_list, :genera => ['Burmomyrma', 'Cananeuretus']}
  #end

  #it "should recognize an extinct subfamily line" do
    #@subfamily_catalog.parse(%{
#<b><span lang=EN-GB>Subfamily *<span style='color:red'>ARMANIINAE</span> <o:p></o:p></span></b></p>
    #}).should == {:type => :subfamily, :name => 'Armaniinae', :fossil => true}
  #end

  #it "should recognize the beginning of a tribe" do
    #@subfamily_catalog.parse(%{
#<b><span lang=EN-GB>Tribe <span style='color:red'>MYRMECIINI</span><o:p></o:p></span></b></p>
    #}).should == {:type => :tribe, :name => 'Myrmeciini'}
  #end

  #it "should recognize the beginning of a fossil tribe" do
    #@subfamily_catalog.parse(%{
#<b><span lang=EN-GB>Tribe *<span style='color:red'>MIOMYRMECINI</span><o:p></o:p></span></b>
    #}).should == {:type => :tribe, :name => 'Miomyrmecini', :fossil => true}
  #end

  #it "should recognize this tribe" do
    #@subfamily_catalog.parse(%{
#<b><span lang=EN-GB>Tribe</span></b><span lang=EN-GB> *<b style='mso-bidi-font-weight:normal'><span style='color:red'>PITYOMYRMECINI</span></b></span>
    #}).should == {:type => :tribe, :name => 'Pityomyrmecini', :fossil => true}
  #end

  #it "should recognize an incertae sedis header in tribe" do
    #@subfamily_catalog.parse(%{
#<b><span lang=EN-GB>Genus <i>incertae sedis</i> in <span style='color:red'>Stenammini</i>
    #}).should == {:type => :incertae_sedis_in_tribe_header}
  #end

  #it "should recognize Hong's incertae sedises" do
    #@subfamily_catalog.parse(%{
#<b><span lang=EN-GB>Genera of Hong (2002), <i>incertae sedis</i> in <span style='color:red'>MYRMICINAE</span><o:p></o:p></span></b>
    #}).should == {:type => :incertae_sedis_in_subfamily_header}
  #end

  #it "should recognize incertae sedis in subfamily" do
    #@subfamily_catalog.parse(%{
#<b><span lang=EN-GB>Genera <i>incertae sedis</i> in <span style='color:red'>MYRMICINAE</span><o:p></o:p></span></b>
    #}).should == {:type => :incertae_sedis_in_subfamily_header}
  #end

  #it "should recognize extinct incertae sedis in subfamily" do
    #@subfamily_catalog.parse(%{
#<b><span lang=EN-GB>Genera (extinct) <i>incertae sedis</i> in <span style='color:red'>DOLICHODERINAE<o:p></o:p></span></span></b>
    #}).should == {:type => :incertae_sedis_in_subfamily_header}
  #end

  #it "should handle it when the span is before the bold and there's a subfamily at the end" do
    #@subfamily_catalog.parse(%{
#<span lang=EN-GB>Genus *<b style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span style='color:red'>YPRESIOMYRMA</span></i></b> [Myrmeciinae]</span>
    #}).should == {:type => :genus, :name => 'Ypresiomyrma', :fossil => true}
  #end

end
