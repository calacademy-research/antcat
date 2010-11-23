require 'spec_helper'

describe SeriesVolumeIssueGrammar do

  it "should recognize and parse a simple volume number" do
    SeriesVolumeIssueGrammar.parse('1').value.should == {:series => '', :volume => '1', :issue => '', :note => ''}
  end

  it "should handle upper and lower-case Roman numerals" do
    SeriesVolumeIssueGrammar.parse('(I)C(xix)').value.should == {:series => '(I)', :volume => 'C', :issue => '(xix)', :note => ''}
  end

  it "should recognize and parse a simple series + volume number" do
    SeriesVolumeIssueGrammar.parse('(1)2').value.should == {:series => '(1)', :volume => '2', :issue => '', :note => ''}
  end

  it "should recognize and parse a simple volume number + issue" do
    SeriesVolumeIssueGrammar.parse('1(2)').value.should == {:series => '', :volume => '1', :issue => '(2)', :note => ''}
  end

  it "should handle '18(suppl.)'" do
    SeriesVolumeIssueGrammar.parse('18(suppl.)').value.should ==  {:series => '', :volume => '18', :issue => '(suppl.)', :note => ''}
  end

  it "should handle '18(suppl.1)'" do
    SeriesVolumeIssueGrammar.parse('18(suppl.1)').value.should ==  {:series => '', :volume => '18', :issue => '(suppl.1)', :note => ''}
  end


  ['14', '43(3)', '16/17', '(n.s.)56', '(2)1[=(3)9]', '113(suppl. 1)', '9(Tropische Binnengewässer 2)',
  ].each do |series_volume_issue|
    it "should recognize '#{series_volume_issue}' as a series_volume_issue" do
      SeriesVolumeIssueGrammar.parse(series_volume_issue).should == series_volume_issue
    end
  end

end
