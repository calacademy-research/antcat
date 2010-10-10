require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HolBibliography do
  describe "getting the contents for an author" do
    before do
      @hol = HolBibliography.new
      @reference = Factory :reference
    end

    it "should get the contents for an author initially" do
      @hol.should_receive(:read_references).and_return []
      @hol.match @reference
    end
    it "should cache an author's contents" do
      @hol.should_receive(:read_references).once().and_return []
      @hol.match @reference
      @hol.match @reference
    end
    it "should get a different author's contents" do
      bolton_reference = Factory :reference, :authors => [Factory(:author, :name => 'Bolton')]
      fisher_reference = Factory :reference, :authors => [Factory(:author, :name => 'Fisher')]
      @hol.should_receive(:read_references).with('Bolton').once().and_return []
      @hol.should_receive(:read_references).with('Fisher').once().and_return []
      @hol.match bolton_reference
      @hol.match fisher_reference
    end
  end

  describe "getting an author's bibliography" do
    before do
      @scraper = mock Scraper
      Scraper.stub!(:new).and_return @scraper
      @hol = HolBibliography.new
    end

    it "should go to the right URL" do
      @scraper.should_receive(:get).with("http://osuc.biosci.ohio-state.edu/hymenoptera/manage_lit.list_pubs?author=fisher").and_return(Nokogiri::HTML '')
      @hol.read_references 'fisher'
    end

    it "should parse each reference" do
      @scraper.stub!(:get).and_return Nokogiri::HTML <<-SEARCH_RESULTS
<HTML>
<HEAD>
<TITLE>Hymenoptera On-Line Database</TITLE>
</HEAD>
<BODY BGCOLOR="#FFFFFF">
<H3>Publications of Barry Bolton:</h3><p>

<li>
<strong><a href="http://holBibliography.osu.edu/reference-full.html?id=22169" title="View extended reference information from Hymenoptera Online">22169</a></strong>
<a href="http://holBibliography.osu.edu/agent-full.html?id=493">Bolton, B.</a> and <a href="http://holbibliography.osu.edu/agent-full.html?id=4746">B. L. Fisher</a>.
 2008. Afrotropical ants of the ponerine genera Centromyrmex Mayr, Promyopias Santschi gen. rev. and Feroponera gen. n., with a revised key to genera of African Ponerinae (Hymenoptera: Formicidae). Zootaxa <strong>1929</strong>: 1-37.
<A HREF="http://osuc.biosci.ohio-state.edu/hymDB/nomenclator.hlviewer?id=22169" TARGET="_blank">Browse</A>
 or download 
<A HREF="http://antbase.org/ants/publications/22169/22169.pdf" TARGET="_blank"> entire file (514K)</A>

<IMG SRC="http://osuc.biosci.ohio-state.edu/images/pdf.gif">
<li>
<strong><a href="http://holBibliography.osu.edu/reference-full.html?id=8085" title="View extended reference information from Hymenoptera Online">8085</a></strong>
<a href="http://holBibliography.osu.edu/agent-full.html?id=493">Bolton, B.</a>
 1999. Ant genera of the tribe Dacetonini (Hymenoptera: Formicidae). Journal of Natural History <strong>33</strong>: 1639-1689.

<a target="_blank" href=http://antbase.org/ants/publications/8085/8085.pdf>(6.2M PDF file)</a>
<IMG SRC="http://osuc.biosci.ohio-state.edu/images/pdf.gif">
<li>
<strong><a href="http://holBibliography.osu.edu/reference-full.html?id=22424" title="View extended reference information from Hymenoptera Online">22424</a></strong>
<a href="http://holBibliography.osu.edu/agent-full.html?id=493">Bolton, B.</a> and <a href="http://holbibliography.osu.edu/agent-full.html?id=4746">B. L. Fisher</a>.
 2008. The Afrotropical ponerine ant genus Phrynoponera Wheeler (Hymenoptera: Formicidae). Zootaxa <strong>1892</strong>: 35-52.
<A HREF="http://osuc.biosci.ohio-state.edu/hymDB/nomenclator.hlviewer?id=22424" TARGET="_blank">Browse</A>
 or download 
<A HREF="http://antbase.org/ants/publications/22424/22424.pdf" TARGET="_blank"> entire file (771K)</A>

<IMG SRC="http://osuc.biosci.ohio-state.edu/images/pdf.gif">
 or download 
<P>
<CENTER>
<a href="http://osuc.biosci.ohio-state.edu/hymDB/hym_utilities.site_stats">
See Site Statistics</a><p>
<IMG SRC="http://iris.biosci.ohio-state.edu/gifs/bl_bds.gif"><P>
<A HREF="http://iris.biosci.ohio-state.edu/hymenoptera/hym_db_form.html">Return to Hymenoptera On-Line Opening Page</A>
<BR>
<A HREF="http://iris.biosci.ohio-state.edu/index.html">Return to OSU Insect Collection Home Page</A>
<BR>
02 September, 2010
</CENTER>
</BODY>
</HTML>
      SEARCH_RESULTS

      @hol.read_references('fisher').should have(3).items
    end

    it "should parse a reference" do
      @scraper.stub!(:get).and_return Nokogiri::HTML <<-SEARCH_RESULTS
<li>
<strong><a href="http://holBibliography.osu.edu/reference-full.html?id=22169" title="View extended reference information from Hymenoptera Online">22169</a></strong>
<a href="http://holBibliography.osu.edu/agent-full.html?id=493">Bolton, B.</a> and <a href="http://holbibliography.osu.edu/agent-full.html?id=4746">B. L. Fisher</a>.
 2008. Afrotropical ants of the ponerine genera Centromyrmex Mayr, Promyopias Santschi gen. rev. and Feroponera gen. n., with a revised key to genera of African Ponerinae (Hymenoptera: Formicidae). Zootaxa <strong>1929</strong>: 1-37.
<A HREF="http://osuc.biosci.ohio-state.edu/hymDB/nomenclator.hlviewer?id=22169" TARGET="_blank">Browse</A>
 or download 
<A HREF="http://antbase.org/ants/publications/22169/22169.pdf" TARGET="_blank"> entire file (514K)</A>

<IMG SRC="http://osuc.biosci.ohio-state.edu/images/pdf.gif">
      SEARCH_RESULTS

      @hol.read_references('fisher').should == [
        {:authors => ['Fisher, B.L.'], :title => 'title', :year => '2010'}
      ]
    end
  end

end
