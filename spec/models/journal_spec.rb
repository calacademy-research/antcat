require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Journal do

  describe "searching" do
    it "do fuzzy matching of journal names" do
      Factory(:reference, :journal => Factory(:journal, :title => 'American Bibliographic Proceedings'))
      Factory(:reference, :journal => Factory(:journal, :title => 'Playboy'))
      Journal.search('ABP').should == ['American Bibliographic Proceedings']
    end
  end

  describe "importing" do
    describe "importing from a file" do
      before do
        @filename = 'foo.htm'
      end

      it "should do nothing if file is empty" do
        File.should_receive(:read).with(@filename).and_return('')
        Journal.import(@filename)
        Journal.all.should be_empty
      end

      it "should import a record from the second row of the first table it finds" do
        @file_contents = "
      <html>

      <head>
      <body link=blue vlink=purple>

      <table border=0 cellpadding=0 cellspacing=0 width=3632>
       <col width=40>
       <col class=xl65 width=661>
       <col class=xl65 width=327>
       <col class=xl65 width=323>
       <col class=xl65 width=1291>
       <col class=xl65 width=50>
       <col class=xl65 width=887>
       <col width=53>
       <tr height=12>
        <td height=12 class=xl67 width=40>RecNo</td>
        <td class=xl68 width=661><a name=Database>Full Title</a></td>
        <td class=xl68 width=327>Serial Abbreviation</td>
        <td class=xl68 width=323>CallNum</td>
        <td class=xl68 width=1291>Notes</td>
        <td class=xl68 width=50>Complete</td>
        <td class=xl68 width=887>Alternate Title</td>
        <td width=53></td>
       </tr>
       <tr height=12>
        <td height=12 align=right>1084</td>
        <td class=xl65>Proceedings of the California Academy of Sciences</td>
        <td class=xl65>Proc. Cal. Acad. Sc.</td>
        <td class=xl65></td>
        <td class=xl65>Melvyl. 1963-1987. Not in SPBM or ZRSS. Cont'd as: Bakonyi
        Termeszsttudomanyi Muzeum Kozlemenyei.</td>
        <td class=xl65>Yes</td>
        <td class=xl65>ZRSS: Termeszettud., ISDS: Termtud.</td>
        <td></td>
       </tr>
       </table></body></html>"

        File.should_receive(:read).with(@filename).and_return(@file_contents)
        Journal.import(@filename)
        journal = Journal.first
        journal.title.should == "Proceedings of the California Academy of Sciences"
        journal.short_title.should == "Proc. Cal. Acad. Sc."
      end

      it "should collapse lines" do
        file_contents = "<html><body><table><tr></tr><tr><td>123</td>
            <td>A long line
            with a linefeed in it.</td>
          <td>A L. L.
            w. a linefeed in it.</td></tr></table></body></html>"
        File.should_receive(:read).with(@filename).and_return(file_contents)
        Journal.import(@filename)
        Journal.first.title.should == 'A long line with a linefeed in it.'
        Journal.first.short_title.should == 'A L. L. w. a linefeed in it.'
      end

      it "should convert entities to characters" do
        file_contents = "<html><body><table><tr></tr><tr><td>123</td>
            <td>Love &amp; Death</td>
            <td>L. &amp; D.</td></tr></table></body></html>"
        File.should_receive(:read).with(@filename).and_return(file_contents)
        Journal.import(@filename)
        Journal.first.title.should == 'Love & Death'
        Journal.first.short_title.should == 'L. & D.'
      end
    end

  end


end
