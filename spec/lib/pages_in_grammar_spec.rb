require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PagesInGrammar do
  it "should handle 'In:'" do
    PagesInGrammar.parse('In:').should == 'In:'
  end
  it "should handle 'Pp. 34-5, 1 in:'" do
    PagesInGrammar.parse('Pp. 34-5, 1 in:').should == 'Pp. 34-5, 1 in:'
  end
  it "should handle 'Pp. 34-5, 1 in:'" do
    PagesInGrammar.parse('Pp. 34-5, 1 in:').should == 'Pp. 34-5, 1 in:'
  end
end
