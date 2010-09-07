require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Reference do

  describe "importing a new reference" do

    it "should import a book reference" do
      data = {:year => 2010, :book => {}}
      BookReference.should_receive(:import).with(data)
      Reference.import data
    end

    it "should import an article reference" do
      data = {:year => 2010, :article => {}}
      ArticleReference.should_receive(:import).with(data)
      Reference.import data
    end

  end

end
