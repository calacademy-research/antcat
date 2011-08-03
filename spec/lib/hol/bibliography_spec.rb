require 'spec_helper'

describe Hol::Bibliography do
  describe "getting an author's bibliography" do
    before do
      @hol = Hol::Bibliography
      @curl_result = mock
      @curl_result.stub(:body_str).and_return ''
    end

    it "should go to the right URL" do
      Curl::Easy.should_receive(:perform).with("http://osuc.biosci.ohio-state.edu/hymenoptera/manage_lit.list_pubs?author=fisher").and_return @curl_result
      @hol.search_for_author 'fisher'
    end

    it "should URL-encode a name with diacritic" do
      utf8 = 'hölldobler'
      Curl::Easy.should_receive(:perform).with("http://osuc.biosci.ohio-state.edu/hymenoptera/manage_lit.list_pubs?author=h%F6lldobler").and_return @curl_result
      @hol.search_for_author utf8
    end

    it "should URL-encode a name with spaces" do
      Curl::Easy.should_receive(:perform).with("http://osuc.biosci.ohio-state.edu/hymenoptera/manage_lit.list_pubs?author=baroni+urbani").and_return @curl_result
      @hol.search_for_author 'baroni urbani'
    end

    it "should convert what it gets from HOL to UTF-8" do
      Curl::Easy.should_receive(:perform).with("http://osuc.biosci.ohio-state.edu/hymenoptera/manage_lit.list_pubs?author=baroni+urbani").and_return @curl_result
      iso_8859_string = 'A' + 246.chr + 'B' # o with diaresis
      utf_8_string = 'A' + 'C3'.to_i(16).chr + 'B6'.to_i(16).chr + 'B'
      @curl_result.should_receive(:body_str).and_return iso_8859_string
      Nokogiri.should_receive(:HTML).with(utf_8_string, nil, 'UTF-8').and_return 'foobar'
      @hol.search_for_author 'baroni urbani'
    end

    it "should convert this dude to ISO" do
      @hol.convert_from_utf8("Csősz, S.")
    end

    it "should parse each reference" do
      Hol::Bibliography.stub(:search_for_author).and_return Nokogiri::HTML <<-SEARCH_RESULTS
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

    it "should parse a reference where the journal name begins with a UTF-8 character" do
      result = @hol.parse_reference(Nokogiri::HTML(<<-LI).at_css('html body'), 'Fisher')
<strong><a href="http://hol.osu.edu/reference-full.html?id=22662" title="View extended reference information from Hymenoptera Online">22662</a></strong>
<a href="http://hol.osu.edu/agent-full.html?id=2767">Adlerz, G.</a>
 1896. Stridulationsorgan och ljudf"ornimmelser hos myror. Öfversigt af Kongliga Ventenskaps-Akadamiens Förhandlingar <strong>52</strong>: 769-782.
<A HREF="http://osuc.biosci.ohio-state.edu/hymDB/nomenclator.hlviewer?id=22662" TARGET="_blank">Browse</A>
 or download 
<A HREF="http://128.146.250.117/pdfs/22662/22662.pdf" TARGET="_blank"> entire file (557k)</A>
<IMG SRC="http://osuc.biosci.ohio-state.edu/images/pdf.gif">
      LI
      result.title.should == 'Stridulationsorgan och ljudf"ornimmelser hos myror'
    end

    it "should at least not crash when information is absent" do
      result = @hol.parse_reference(Nokogiri::HTML(<<-LI).at_css('html body'), 'Fisher')
<strong><a href="http://hol.osu.edu/reference-full.html?id=22662" title="View extended reference information from Hymenoptera Online">22662</a></strong>
<a href="http://hol.osu.edu/agent-full.html?id=2767">Adlerz, G.</a>
 1846. Nomenclatoris zoologici index universalis, continens nomina systematica classium, ordinum, familiarum, et generum animalium omnium.... Soloduri, .
<A HREF="http://osuc.biosci.ohio-state.edu/hymDB/nomenclator.hlviewer?id=22662" TARGET="_blank">Browse</A>
 or download 
<A HREF="http://128.146.250.117/pdfs/22662/22662.pdf" TARGET="_blank"> entire file (557k)</A>
<IMG SRC="http://osuc.biosci.ohio-state.edu/images/pdf.gif">
      LI
      result.title.should be_nil
    end

    it "should parse an article reference" do
      result = @hol.parse_reference(Nokogiri::HTML(<<-LI).at_css('html body'), 'Fisher')
<strong><a href="http://holBibliography.osu.edu/reference-full.html?id=22169" title="View extended reference information from Hymenoptera Online">22169</a></strong>
<a href="http://holBibliography.osu.edu/agent-full.html?id=493">Bolton, B.</a> and <a href="http://holbibliography.osu.edu/agent-full.html?id=4746">B. L. Fisher</a>.
 2008. Afrotropical ants of the ponerine genera Centromyrmex Mayr, Promyopias Santschi gen. rev. and Feroponera gen. n., with a revised key to genera of African Ponerinae (Hymenoptera: Formicidae). Zootaxa <strong>1929</strong>(1): 1-37.
<A HREF="http://osuc.biosci.ohio-state.edu/hymDB/nomenclator.hlviewer?id=22169" TARGET="_blank">Browse</A>
 or download 
<A HREF="http://antbase.org/ants/publications/22169/22169.pdf" TARGET="_blank"> entire file (514K)</A>

<IMG SRC="http://osuc.biosci.ohio-state.edu/images/pdf.gif">
      LI

      result.document_url.should == 'http://antbase.org/ants/publications/22169/22169.pdf'
      result.year.should == 2008
      result.series_volume_issue.should == '1929(1)'
      result.title.should == 'Afrotropical ants of the ponerine genera Centromyrmex Mayr, Promyopias Santschi gen. rev. and Feroponera gen. n., with a revised key to genera of African Ponerinae (Hymenoptera: Formicidae)'
      result.pagination.should == '1-37'
    end

    it "should parse an article reference with a single author" do
      result = @hol.parse_reference(Nokogiri::HTML(<<-LI).at_css('html body'), 'Fisher')
<strong><a href="http://hol.osu.edu/reference-full.html?id=22497" title="View extended reference information from Hymenoptera Online">22497</a></strong>
<a href="http://hol.osu.edu/agent-full.html?id=2767">Adlerz, G.</a>
 1887. Myrmecologiska notiser. Entomologisk Tidskrift <strong>8</strong>: 41-50.
<A HREF="http://osuc.biosci.ohio-state.edu/hymDB/nomenclator.hlviewer?id=22497" TARGET="_blank">Browse</A>
 or download 
<A HREF="http://128.146.250.117/pdfs/22497/22497.pdf" TARGET="_blank"> entire file (583k)</A>
<IMG SRC="http://osuc.biosci.ohio-state.edu/images/pdf.gif">
      LI

      result.title.should == 'Myrmecologiska notiser'
    end

    it "should parse a book reference" do
      result = @hol.parse_reference(Nokogiri::HTML(<<-LI).at_css('html body'), 'Fisher')
<strong><a href=\"http://hol.osu.edu/reference-full.html?id=6373\" title=\"View extended reference information from Hymenoptera Online\">6373</a></strong>\n<a href=\"http://hol.osu.edu/agent-full.html?id=2711\">Foerster, J. R.</a>\n 1771. Novae species insectorum. Centuria I. T. Davies, London. 100 pp.\n<p>\n</p>\n<center>\n<a href=\"http://osuc.biosci.ohio-state.edu/hymDB/hym_utilities.site_stats\">\nSee Site Statistics</a><p>\n<img src=\"http://iris.biosci.ohio-state.edu/gifs/bl_bds.gif\"></p>\n<p>\n<a href=\"http://iris.biosci.ohio-state.edu/hymenoptera/hym_db_form.html\">Return to Hymenoptera On-Line Opening Page</a>\n<br><a href=\"http://iris.biosci.ohio-state.edu/index.html\">Return to OSU Insect Collection Home Page</a>\n<br>\n10 October  , 2010\n</p>\n</center>\n\n\n\n\n<title>Hymenoptera On-Line Database</title>\n<script language=\"JAVASCRIPT\">\n<!-- Hide script from old browsers\nfunction popup(url, x, y) {\n  newWindow = window.open(url, \"coverwin\",\n    \"toolbar=yes,directories=yes,menubar=yes,status=yes,width=800,height=600,resizable=yes,scrollbars=yes\")\n  newWindow.focus()\n}\n// end hiding script from old browsers -->\n</script><title>Hymenoptera On-Line Database</title>\n<script language=\"JAVASCRIPT\">\n<!-- Hide script from old browsers\nfunction popup(url, x, y) {\n  newWindow = window.open(url, \"coverwin\",\n    \"toolbar=yes,directories=yes,menubar=yes,status=yes,width=800,height=600,resizable=yes,scrollbars=yes\")\n  newWindow.focus()\n}\n// end hiding script from old browsers -->\n</script><h3>Publications of Luis A. Foerster:</h3>\n<p>\n</p>
      LI
      result.document_url.should == 'http://antbase.org/ants/publications/6373/6373.pdf'
      result.year.should == 1771
      result.pagination.should == '100 pp.'
    end

    it "should parse the URL out of the document, if it exists" do
      result = @hol.parse_reference(Nokogiri::HTML(<<-LI).at_css('html body'), 'Fisher')
                <strong><a href="http://hol.osu.edu/reference-full.html?id=22497" title="View extended reference information from Hymenoptera Online">22497</a></strong>
                <a href="http://hol.osu.edu/agent-full.html?id=2767">Adlerz, G.</a>
                 1887. Myrmecologiska notiser. Entomologisk Tidskrift <strong>8</strong>: 41-50.
                 <A HREF="http://osuc.biosci.ohio-state.edu/hymDB/nomenclator.hlviewer?id=22497" TARGET="_blank">Browse</A>
                  or download 
                  <A HREF="http://128.146.250.117/pdfs/22497/22497.pdf" TARGET="_blank"> entire file (583k)</A>
                  <IMG SRC="http://osuc.biosci.ohio-state.edu/images/pdf.gif">
      LI

      result.document_url.should == "http://128.146.250.117/pdfs/22497/22497.pdf" 
    end

    it "should set the author" do
      result = @hol.parse_reference(Nokogiri::HTML(<<-LI).at_css('html body'), 'Fisher')
                  <strong><a href="http://hol.osu.edu/reference-full.html?id=22497" title="View extended reference information from Hymenoptera Online">22497</a></strong>
                  <a href="http://hol.osu.edu/agent-full.html?id=2767">Adlerz, G.</a>
                  1887. Myrmecologiska notiser. Entomologisk Tidskrift <strong>8</strong>: 41-50.
                  <A HREF="http://osuc.biosci.ohio-state.edu/hymDB/nomenclator.hlviewer?id=22497" TARGET="_blank">Browse</A>
                    or download 
                    <A HREF="http://128.146.250.117/pdfs/22497/22497.pdf" TARGET="_blank"> entire file (583k)</A>
                    <IMG SRC="http://osuc.biosci.ohio-state.edu/images/pdf.gif">
        LI
      result.author.should == 'Fisher'
    end
  end

end
