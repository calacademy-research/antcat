require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Issue do
  it "has a journal" do
    journal = Journal.create! :title => 'Antucopia'
    issue = Issue.create!

    issue.journal = journal
    issue.save!

    issue.reload.journal.should == journal
  end

  describe "importing" do
    it "should create the issue and set its journal and other information" do
      issue = Issue.import(:journal => {:title => 'Ecology Letters'}, :series => nil, :volume => '12', :issue => nil)

      issue.series.should be_nil
      issue.volume.should == '12'
      issue.issue.should be_nil

      journal = issue.journal
      journal.title.should == 'Ecology Letters'
    end
  end
end
