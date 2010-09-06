require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Article do

=begin
  describe "importing" do
    it "should create the article if it's new" do

      article = Article.import({:authors => 'Fisher, B.L.', :year => 2010, :title => 'Ants',
        :article => {:publisher => {:place => 'New York', :name => 'Oxford'}, :pagination => '26 pp'}})

      article.authors.should == 'Fisher, B.L.'
      article.year.should == 2010
      article.title.should == 'Ants'
      article.place.should == 'New York'
      article.publisher.should == 'Oxford'
      article.pagination.should == '26 pp'
    end

    it "should not create the article if it already exists" do
      article.create!(:authors => 'Fisher, B.L.', :year => 2010, :title => 'Ants', :place => 'New York', :publisher => 'Oxford',
        :pagination => '26 pp')

      article = Book.import({:authors => 'Fisher, B.L.', :year => 2010, :title => 'Ants',
        :article => {:publisher => {:place => 'New York', :name => 'Oxford'}, :pagination => '26 pp'}})

      article.count.should == 1
      article.authors.should == 'Fisher, B.L.'
      article.year.should == 2010
      article.title.should == 'Ants'
      article.place.should == 'New York'
      article.publisher.should == 'Oxford'
      article.pagination.should == '26 pp'
    end
  end
=end
end
