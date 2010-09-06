require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Article do
  it "has authors" do
    author = Author.create! :name => 'Fisher, B.L.'
    article = Article.create!

    article.authors << author

    article.reload.authors.should == [author.reload]
  end

  it "has an issue" do
    issue = Issue.create!
    article = Article.create!

    article.issue = issue
    article.save!

    article.reload.issue.should == issue
  end

  describe "importing" do
    it "should create the article and set its issue, authors and other information" do
      article = Article.import({:authors => ['Fisher, B.L.'], :year => 2010, :title => 'Ants',
        :article => {
          :issue => {:journal => {:title => 'Ecology Letters'}, :series => nil, :volume => '12', :issue => nil},
          :start_page => '324', :end_page => '333'}})

      article.authors.map(&:name).should == ['Fisher, B.L.']

      issue = article.issue
      issue.series.should be_nil
      issue.volume.should == '12'
      issue.issue.should be_nil

      journal = issue.journal
      journal.title.should == 'Ecology Letters'

      article.year.should == 2010
      article.title.should == 'Ants'

      article.start_page.should == '324'
      article.end_page.should == '333'
    end
  end
end
