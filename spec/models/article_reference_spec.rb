require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ArticleReference do

  describe "importing" do

    it "should create the reference and set its data" do
      reference = ArticleReference.import({}, {:issue => '12', :pagination => '32-33', :journal => 'Ecology Letters'})
      reference.issue.should == '12'
      reference.pagination.should == '32-33'
      reference.journal.title.should == 'Ecology Letters'
    end

  end
end
