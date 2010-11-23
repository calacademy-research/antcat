require 'spec_helper'

describe SeriesVolumeIssueStringGrammar do

  it "should recognize and parse a simple volume number" do
    SeriesVolumeIssueStringGrammar.parse(' 1:').value.should == '1'
  end

  it "should handle upper and lower-case Roman numerals" do
    SeriesVolumeIssueStringGrammar.parse(' (I)C(xix):').value.should == '(I)C(xix)'
  end

  it "should recognize and parse a simple parenthesized phrase" do
    SeriesVolumeIssueStringGrammar.parse(' (1):').value.should == '(1)'
  end

  it "should recognize and parse a simple series + volume number" do
    SeriesVolumeIssueStringGrammar.parse(' (1)2:').value.should == '(1)2'
  end

  it "should recognize and parse a simple volume number + issue" do
    SeriesVolumeIssueStringGrammar.parse(' 1(2):').value.should == '1(2)'
  end

  it "should recognize and parse a special case" do
    SeriesVolumeIssueStringGrammar.parse(' Secunda Era 2:').value.should == 'Secunda Era 2'
  end

  it "should handle '18(suppl.)'" do
    SeriesVolumeIssueStringGrammar.parse(' 18(suppl.):').value.should == '18(suppl.)'
  end

  it "should handle '18(suppl.1)'" do
    SeriesVolumeIssueStringGrammar.parse(' 18(suppl.1):').value.should == '18(suppl.1)'
  end

  it "should handle '18(suppl. 1)'" do
    SeriesVolumeIssueStringGrammar.parse(' 18(suppl. 1):').value.should == '18(suppl. 1)'
  end

  it "should handle nested parentheses" do
    SeriesVolumeIssueStringGrammar.parse(' 6(3(c)):').value.should == '6(3(c))'
  end

  ['14', '43(3)', '16/17', '(n.s.)56', '(2)1[=(3)9]', '113(suppl. 1)', '9(Tropische Binnengewässer 2)',
  ].each do |series_volume_issue|
    it "should recognize '#{series_volume_issue}' as a series_volume_issue" do
      SeriesVolumeIssueStringGrammar.parse(' ' + series_volume_issue + ':').value.should == series_volume_issue
    end
  end

end
