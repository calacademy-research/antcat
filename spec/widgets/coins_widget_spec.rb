require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "COinS widget" do
  it "should format a journal reference correctly" do
    @widget = Views::Coins.new(:reference => Factory(:reference, {
      :kind => 'journal',
      :title => 'A title',
      :short_journal_title => 'Sh. Jrnl. Title',
      :volume => '1',
      :issue => '2',
      :start_page => '3',
      :end_page => '4',
      :year => '1941',
      :numeric_year => 1941,
    }))
    check_parameters [
      "ctx_ver=Z39.88-2004",
      "rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal",
      "rfr_id=antcat.org",
      "rft.genre=article",
      "rft.atitle=A+title",
      "rft.jtitle=Sh.+Jrnl.+Title",
      "rft.volume=1",
      "rft.issue=2",
      "rft.spage=3",
      "rft.epage=4",
      "rft.date=1941"
    ]
  end

  it "should use the numeric year" do
    @widget = Views::Coins.new(:reference => Factory(:reference, {
      :kind => 'journal',
      :title => 'A title',
      :short_journal_title => 'Sh. Jrnl. Title',
      :volume => '1',
      :issue => '2',
      :start_page => '3',
      :end_page => '4',
      :year => '1941a ("1942")',
      :numeric_year => 1941,
    }))
    check_parameters [
      "ctx_ver=Z39.88-2004",
      "rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal",
      "rfr_id=antcat.org",
      "rft.genre=article",
      "rft.atitle=A+title",
      "rft.jtitle=Sh.+Jrnl.+Title",
      "rft.volume=1",
      "rft.issue=2",
      "rft.spage=3",
      "rft.epage=4",
      "rft.date=1941"
    ]
  end

  it "should add multiple authors" do
    @widget = Views::Coins.new(:reference => Factory(:reference, {
      :kind => 'journal',
      :title => 'A title',
      :short_journal_title => 'Sh. Jrnl. Title',
      :authors => 'MacKay, W. P.; Lowrie, D.',
      :volume => '1',
      :issue => '2',
      :start_page => '3',
      :end_page => '4',
      :year => '1941',
      :numeric_year => 1941,
    }))
    check_parameters [
      "ctx_ver=Z39.88-2004",
      "rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal",
      "rfr_id=antcat.org",
      "rft.genre=article",
      "rft.atitle=A+title",
      "rft.jtitle=Sh.+Jrnl.+Title",
      "rft.volume=1",
      "rft.issue=2",
      "rft.spage=3",
      "rft.epage=4",
      "rft.date=1941",
      "rft.aulast=MacKay",
      "rft.aufirst=W.+P.",
      "rft.aulast=Lowrie",
      "rft.aufirst=D.",
    ]
  end

  it "should handle authors without commas" do
    @widget = Views::Coins.new(:reference => Factory(:reference, {
      :kind => 'journal',
      :title => 'A title',
      :short_journal_title => 'Sh. Jrnl. Title',
      :authors => 'author',
      :volume => '1',
      :issue => '2',
      :start_page => '3',
      :end_page => '4',
      :year => '1941',
      :numeric_year => 1941,
    }))
    check_parameters [
      "ctx_ver=Z39.88-2004",
      "rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal",
      "rfr_id=antcat.org",
      "rft.genre=article",
      "rft.atitle=A+title",
      "rft.jtitle=Sh.+Jrnl.+Title",
      "rft.volume=1",
      "rft.issue=2",
      "rft.spage=3",
      "rft.epage=4",
      "rft.date=1941",
      "rft.au=author",
    ]
  end

  it "should strip out italics formatting" do
    @widget = Views::Coins.new(:reference => Factory(:reference, {
      :kind => 'journal',
      :title => '*A title*',
      :short_journal_title => '|Sh. Jrnl. Title|',
      :volume => '1',
      :issue => '2',
      :start_page => '3',
      :end_page => '4',
      :year => '1941',
      :numeric_year => 1941,
    }))
    check_parameters [
      "ctx_ver=Z39.88-2004",
      "rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal",
      "rfr_id=antcat.org",
      "rft.genre=article",
      "rft.atitle=A+title",
      "rft.jtitle=Sh.+Jrnl.+Title",
      "rft.volume=1",
      "rft.issue=2",
      "rft.spage=3",
      "rft.epage=4",
      "rft.date=1941"
    ]
  end

  it "should format a book reference correctly" do
    @widget = Views::Coins.new(:reference => Factory(:reference, {
      :kind => 'book',
      :title => 'Another title',
      :year => '1933',
      :numeric_year => 1933,
      :publisher => 'Springer, Verlag',
      :place => 'Dresden',
    }))
    check_parameters [
      "ctx_ver=Z39.88-2004",
      "rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Abook",
      "rfr_id=antcat.org",
      "rft.genre=book",
      "rft.btitle=Another+title",
      "rft.pub=Springer%2C+Verlag",
      "rft.place=Dresden",
      "rft.date=1933",
    ]
  end

  it "should format an unknown/nested reference correctly" do
    @widget = Views::Coins.new(:reference => Factory(:reference, :kind => 'unknown'))
    check_parameters [
      "ctx_ver=Z39.88-2004",
      "rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Aunknown",
      "rfr_id=antcat.org",
      "rft.genre=",
    ]
  end

  def check_parameters expected_parameters
    html = @widget.to_html
    match = html.match(/<span class="Z3988" title="(.*)"/)
    match.should_not be_nil
    match[1].should_not be_nil
    parameters = match[1].split("&amp;")
    parameters.should =~ expected_parameters
  end
end
