require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PdfLinkImporter do
  it "should do nothing if there are no references" do
    PdfLinkImporter.new.import
  end

  it "should find the PDF link when it finds a matching reference" do
    author = Factory :author, :name => 'Bolton, B.'
    journal = Factory :journal, :title => 'Journal of Natural History'
    reference = Factory :article_reference, :authors => [author], :year => '1999', :journal => journal,
                        :title => "Ant genera of the tribe Dacetonini (Hymenoptera: Formicidae)",
                        :series_volume_issue => '33', :pagination => '1639-1689'

    scraper = mock
    Scraper.should_receive(:new).and_return scraper
    content = <<-CONTENT
<HTML>
<HEAD>
<TITLE>Hymenoptera On-Line Database</TITLE>
</HEAD>
<BODY BGCOLOR="#FFFFFF">
<HTML>
<HEAD>
<TITLE>Hymenoptera On-Line Database</TITLE>
</HEAD>
<BODY BGCOLOR="#FFFFFF">
<H3>Publications of Barry Bolton:</h3><p>

<li>
<strong><a href="http://hol.osu.edu/reference-full.html?id=22169" title="View extended reference information from Hymenoptera Online">22169</a></strong>
<a href="http://hol.osu.edu/agent-full.html?id=493">Bolton, B.</a> and <a href="http://hol.osu.edu/agent-full.html?id=4746">B. L. Fisher</a>.
 2008. Afrotropical ants of the ponerine genera Centromyrmex Mayr, Promyopias Santschi gen. rev. and Feroponera gen. n., with a revised key to genera of African Ponerinae (Hymenoptera: Formicidae). Zootaxa <strong>1929</strong>: 1-37.
<A HREF="http://osuc.biosci.ohio-state.edu/hymDB/nomenclator.hlviewer?id=22169" TARGET="_blank">Browse</A>
 or download 
<A HREF="http://antbase.org/ants/publications/22169/22169.pdf" TARGET="_blank"> entire file (514K)</A>

<IMG SRC="http://osuc.biosci.ohio-state.edu/images/pdf.gif">
<li>
<strong><a href="http://hol.osu.edu/reference-full.html?id=8085" title="View extended reference information from Hymenoptera Online">8085</a></strong>
<a href="http://hol.osu.edu/agent-full.html?id=493">Bolton, B.</a>
 1999. Ant genera of the tribe Dacetonini (Hymenoptera: Formicidae). Journal of Natural History <strong>33</strong>: 1639-1689.

<a target="_blank" href=http://antbase.org/ants/publications/8085/8085.pdf>(6.2M PDF file)</a>
<IMG SRC="http://osuc.biosci.ohio-state.edu/images/pdf.gif">
<li>
<strong><a href="http://hol.osu.edu/reference-full.html?id=22424" title="View extended reference information from Hymenoptera Online">22424</a></strong>
<a href="http://hol.osu.edu/agent-full.html?id=493">Bolton, B.</a> and <a href="http://hol.osu.edu/agent-full.html?id=4746">B. L. Fisher</a>.
 2008. The Afrotropical ponerine ant genus Phrynoponera Wheeler (Hymenoptera: Formicidae). Zootaxa <strong>1892</strong>: 35-52.
<A HREF="http://osuc.biosci.ohio-state.edu/hymDB/nomenclator.hlviewer?id=22424" TARGET="_blank">Browse</A>
 or download 
<A HREF="http://antbase.org/ants/publications/22424/22424.pdf" TARGET="_blank"> entire file (771K)</A>

<IMG SRC="http://osuc.biosci.ohio-state.edu/images/pdf.gif">
<li>
<strong><a href="http://hol.osu.edu/reference-full.html?id=6455" title="View extended reference information from Hymenoptera Online">6455</a></strong>
<a href="http://hol.osu.edu/agent-full.html?id=493">Bolton, B.</a>, <a href="http://hol.osu.edu/agent-full.html?id=1754">W. H. Gotwald</a> and <a href="http://hol.osu.edu/agent-full.html?id=2236">J. M. Leroux</a>.
 1979. A new West African ant of the genus Plectroctena with ecological notes (Hymenoptera: Formicidae). Annales de l'Universite de l'Abidjan (Sciences) (E)<strong>9</strong>: 373-381.
<A HREF="http://osuc.biosci.ohio-state.edu/hymDB/nomenclator.hlviewer?id=6455" TARGET="_blank">Browse</A>
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
    CONTENT

    scraper.should_receive(:get).with("http://osuc.biosci.ohio-state.edu/hymenoptera/manage_lit.list_pubs?author=bolton").
      and_return Nokogiri.HTML(content)
    PdfLinkImporter.new.import
    reference.reload.pdf_link.should == 'http://antbase.org/ants/publications/20340/20340.pdf'
  end

  it "should not find a PDF link when there isn't a matching reference"
  it "should set the 'tried' flag whether it finds a matching reference or not"
end
