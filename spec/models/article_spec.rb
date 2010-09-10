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

  describe "importing a new Article" do
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

    it "should find an existing article" do
      data = {:authors => ['Fisher, B.L.'], :year => 2010, :title => 'Ants',
        :article => {
          :issue => {:journal => {:title => 'Ecology Letters'}, :series => nil, :volume => '12', :issue => nil},
          :start_page => '324', :end_page => '333'}}
      Article.import(data)
      Article.import(data)
      Article.count.should == 1
    end

  end

  describe "importing into an existing article" do
    describe "when the volume number of the issue changes" do
      it "should create and link to a new issue" do
        data = {:authors => ['Fisher, B.L.'], :year => 2010, :title => 'Ants',
          :article => {
            :issue => {:journal => {:title => 'Ants'}, :series => nil, :volume => '1', :issue => nil},
            :start_page => '324', :end_page => '333'}}
        article = Article.import data
        issue = article.issue
        journal = issue.journal

        data[:article][:issue][:volume] = '2'
        new_article = article.import data

        Issue.count.should == 1
        Issue.find_by_id(issue.id).should be_nil
        new_article.issue.journal.should == journal
        new_article.issue.volume.should == '2'
      end
    end

    it "should create a new journal, linked to a new issue, if a new journal title is passed" do
        data = {:authors => ['Fisher, B.L.'], :year => 2010, :title => 'Ants',
          :article => {
            :issue => {:journal => {:title => 'Ants'}, :series => nil, :volume => '1', :issue => nil},
            :start_page => '324', :end_page => '333'}}
        article = Article.import data
        issue = article.issue
        journal = issue.journal

        data[:article][:issue][:journal][:title] = 'Bees'
        new_article = article.import data

        new_article.issue.should_not == issue
        new_article.issue.journal.should_not == journal
        new_article.issue.journal.title.should == 'Bees'
        Journal.count.should == 1
        Issue.count.should == 1
    end
  end
end
