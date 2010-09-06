require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ArticleReference do

  describe "importing a new reference" do
    it "should create and return an ArticleReference with the passed-in data" do
      article = mock_model Article
      Article.should_receive(:import).with({}).and_return article

      reference = ArticleReference.import({})

      ArticleReference.first.should == reference
      reference.article.should == article
    end
  end
end
