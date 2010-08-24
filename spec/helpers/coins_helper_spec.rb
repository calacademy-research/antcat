require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CoinsHelper do
  it "should format a journal reference correctly" do
    coins = helper.coins(Factory(:reference,
      :authors => 'MacKay, W.',
      :kind => 'journal',
      :title => 'A title',
      :journal_title => 'Journal Title',
      :volume => '1',
      :issue => '2',
      :start_page => '3',
      :end_page => '4',
      :year => '1941',
      :numeric_year => 1941
    ))
    check_parameters coins, [
      "ctx_ver=Z39.88-2004",
      "rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal",
      "rfr_id=antcat.org",
      "rft.aulast=MacKay",
      "rft.aufirst=W.",
      "rft.genre=article",
      "rft.atitle=A+title",
      "rft.jtitle=Journal+Title",
      "rft.volume=1",
      "rft.issue=2",
      "rft.spage=3",
      "rft.epage=4",
      "rft.date=1941"
    ]
  end

  it "should use the numeric year" do
    coins = helper.coins(Factory(:reference,
      :authors => 'MacKay, W.',
      :kind => 'journal',
      :title => 'A title',
      :volume => '1',
      :issue => '2',
      :start_page => '3',
      :end_page => '4',
      :year => '1941a ("1942")',
      :numeric_year => 1941
    ))
    check_parameters coins, [
      "ctx_ver=Z39.88-2004",
      "rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal",
      "rft.aulast=MacKay",
      "rft.aufirst=W.",
      "rfr_id=antcat.org",
      "rft.genre=article",
      "rft.atitle=A+title",
      "rft.volume=1",
      "rft.issue=2",
      "rft.spage=3",
      "rft.epage=4",
      "rft.date=1941"
    ]
  end

  it "should add multiple authors" do
    coins = helper.coins(Factory(:reference,
      :kind => 'journal',
      :title => 'A title',
      :authors => 'MacKay, W. P.; Lowrie, D.',
      :volume => '1',
      :issue => '2',
      :start_page => '3',
      :end_page => '4',
      :year => '1941',
      :numeric_year => 1941
    ))
    check_parameters coins, [
      "ctx_ver=Z39.88-2004",
      "rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal",
      "rfr_id=antcat.org",
      "rft.genre=article",
      "rft.atitle=A+title",
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
    coins = helper.coins(Factory(:reference,
      :kind => 'journal',
      :title => 'A title',
      :authors => 'author',
      :volume => '1',
      :issue => '2',
      :start_page => '3',
      :end_page => '4',
      :year => '1941',
      :numeric_year => 1941
    ))
    check_parameters coins, [
      "ctx_ver=Z39.88-2004",
      "rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal",
      "rfr_id=antcat.org",
      "rft.genre=article",
      "rft.atitle=A+title",
      "rft.volume=1",
      "rft.issue=2",
      "rft.spage=3",
      "rft.epage=4",
      "rft.date=1941",
      "rft.au=author",
    ]
  end

  it "should strip out italics formatting" do
    coins = helper.coins(Factory(:reference,
      :authors => 'MacKay, W.',
      :kind => 'journal',
      :title => '*A title*',
      :volume => '1',
      :issue => '2',
      :start_page => '3',
      :end_page => '4',
      :year => '1941',
      :numeric_year => 1941
    ))
    check_parameters coins, [
      "ctx_ver=Z39.88-2004",
      "rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal",
      "rft.aulast=MacKay",
      "rft.aufirst=W.",
      "rfr_id=antcat.org",
      "rft.genre=article",
      "rft.atitle=A+title",
      "rft.volume=1",
      "rft.issue=2",
      "rft.spage=3",
      "rft.epage=4",
      "rft.date=1941"
    ]
  end

  it "should format a book reference correctly" do
    coins = helper.coins(Factory(:reference,
      :authors => 'MacKay, W.',
      :kind => 'book',
      :title => 'Another title',
      :year => '1933',
      :numeric_year => 1933,
      :publisher => 'Springer, Verlag',
      :place => 'Dresden',
      :pagination => 'ix + 33pp.'
    ))
    check_parameters coins, [
      "ctx_ver=Z39.88-2004",
      "rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Abook",
      "rft.aulast=MacKay",
      "rft.aufirst=W.",
      "rfr_id=antcat.org",
      "rft.genre=book",
      "rft.btitle=Another+title",
      "rft.pub=Springer%2C+Verlag",
      "rft.place=Dresden",
      "rft.date=1933",
      "rft.pages=ix+%2B+33pp.",
    ]
  end

  it "should format an unknown/nested reference correctly" do
    coins = helper.coins(Factory(:reference, :kind => 'unknown'))
    check_parameters coins, [
      "ctx_ver=Z39.88-2004",
      "rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Aunknown",
      "rft.aulast=Fisher",
      "rft.aufirst=B.L.",
      "rfr_id=antcat.org",
      "rft.genre=",
    ]
  end

  def check_parameters coins, expected_parameters
    match = coins.match(/<span class="Z3988" title="(.*)"/)
    match.should_not be_nil
    match[1].should_not be_nil
    parameters = match[1].split("&amp;")
    parameters.should =~ expected_parameters
  end
end
