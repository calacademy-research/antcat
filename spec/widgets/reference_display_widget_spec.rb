require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Reference display widget" do
  it "should format the reference" do
    reference = Factory.build(:reference, :authors => "Forel, A.", :year => "1874", :title => "Les fourmis de la Suisse",
                              :citation => "Neue Denkschriften 26:1-452")
    widget = Views::References::Display.new(:reference => reference)
    widget.format_reference.should == 'Forel, A. 1874. Les fourmis de la Suisse. Neue Denkschriften 26:1-452.'
  end

  it "should add a period after the title if none exists" do
    widget = Views::References::Display.new(:reference => Factory.build(:reference, :title => 'No period'))
    widget.format_reference.should == ' . No period. '
  end

  it "should not add a period after the title if there's already one" do
    widget = Views::References::Display.new(:reference => Factory.build(:reference, :title => 'With period.'))
    widget.format_reference.should == ' . With period. '
  end

  it "should add a period after the citation if none exists" do
    widget = Views::References::Display.new(:reference => Factory.build(:reference, :citation => 'No period'))
    widget.format_reference.should == ' .  No period.'
  end

  it "should not add a period after the citation if there's already one" do
    widget = Views::References::Display.new(:reference => Factory.build(:reference, :citation => 'With period.'))
    widget.format_reference.should == ' .  With period.'
  end
end

