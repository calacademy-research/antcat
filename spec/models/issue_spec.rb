require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Issue do
  it "has a journal" do
    journal = Journal.create! :title => 'Antucopia'
    issue = Issue.create!

    issue.journal = journal
    issue.save!

    issue.reload.journal.should == journal
  end

  it "has many articles" do
    issue = Issue.create!
    article = Article.create! :issue => issue
    issue.articles = [article]
  end

  describe "importing a new issue" do
    it "should create the issue and set its journal and other information" do
      issue = Issue.import(:journal => {:title => 'Ecology Letters'}, :series => nil, :volume => '12', :issue => nil)

      issue.series.should be_nil
      issue.volume.should == '12'
      issue.issue.should be_nil

      journal = issue.journal
      journal.title.should == 'Ecology Letters'
    end

    it "should find an existing issue" do
      Issue.import(:journal => {:title => 'Ecology Letters'}, :series => nil, :volume => '12', :issue => nil)
      Issue.import(:journal => {:title => 'Ecology Letters'}, :series => nil, :volume => '12', :issue => nil)
      Issue.count.should == 1
    end
  end

  describe "importing into an existing issue" do
    describe "changing the journal title" do
      describe "when no other issues for that journal" do
        it "should add the new journal and delete the old one" do
          journal = Factory :journal, :title => 'Ants'
          issue = Issue.create! :journal => journal

          new_issue = issue.import :journal => {:title => 'Ecology Letters'}, :series => nil, :volume => '12', :issue => nil

          new_issue.journal.title.should == 'Ecology Letters'
          Journal.count.should == 1
          Journal.find_by_title('Ants').should be_nil
        end
      end

      describe "when there are other issues for that journal" do
        it "should add the new journal and leave the old one" do
          journal = Factory :journal, :title => 'Ants'
          Issue.create! :journal => journal, :volume => '1'
          issue = Issue.create! :journal => journal, :volume => '2'

          new_issue = issue.import :journal => {:title => 'Ecology Letters'}, :series => nil, :volume => '12', :issue => nil

          new_issue.journal.title.should == 'Ecology Letters'
          Journal.count.should == 2
          Journal.find_by_title('Ants').should_not be_nil
        end
      end

      describe "when the new journal already exists, and when there are other issues for the old journal" do
        it "should create a new issue and use the existing journal" do
          ants_journal = Factory(:journal, :title => 'Ants')
          fleas_journal = Factory(:journal, :title => 'Fleas')
          Issue.create!(:journal => ants_journal, :volume => '1')
          Issue.create!(:journal => fleas_journal, :volume => '10')
          issue = Issue.create!(:journal => ants_journal, :volume => '222')

          new_issue = issue.import(:journal => {:title => 'Fleas'}, :series => nil, :volume => '222', :issue => nil)

          new_issue.journal.title.should == 'Fleas'
          Journal.count.should == 2
          Journal.find_by_title('Ants').should_not be_nil
          Journal.find_by_title('Fleas').should_not be_nil
          Issue.count.should == 3
        end
      end

      describe "when the journal name doesn't actually change" do
        it "should set the issue to a new issue, but the same journal" do
          data = {:journal => {:title => 'Ants'}, :series => nil, :volume => '1', :issue => nil}
          original_issue = Issue.import data
          original_journal = original_issue.journal

          data[:volume] = '2'
          changed_issue = original_issue.import data

          changed_issue.should_not == original_issue
          lll{'changed_issue'}
          changed_issue.journal.should == original_journal
          Journal.count.should == 1
          Issue.count.should == 1
        end
      end
    end
  end
end
