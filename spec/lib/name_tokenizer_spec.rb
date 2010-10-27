require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe NameTokenizer do

  describe "phrases" do
    it "should get words joined by spaces" do
      tokenizer = NameTokenizer.new "Mark Wilden"
      tokenizer.get.should == :phrase
      tokenizer.get.should == :eos
    end
    it "should allow hyphens" do
      tokenizer = NameTokenizer.new "Abdul-Rassoul"
      tokenizer.get.should == :phrase
      tokenizer.get.should == :eos
    end
    it "should allow apostrophes" do
      tokenizer = NameTokenizer.new "Passerin d'Entrèves"
      tokenizer.get.should == :phrase
      tokenizer.get.should == :eos
    end
    it "should handle abbreviations inside phrases" do
      tokenizer = NameTokenizer.new "St. James"
      tokenizer.get.should == :phrase
      tokenizer.get.should == :eos
    end
  end

  describe "initials" do
    it "should get an initial" do
      tokenizer = NameTokenizer.new "Wilden, M.A."
      tokenizer.get.should == :phrase
      tokenizer.get.should == :comma
      tokenizer.get.should == :initial
      tokenizer.get.should == :initial
      tokenizer.get.should == :eos
    end
    it "should get an initial with a hyphen" do
      tokenizer = NameTokenizer.new "Kim, B.-J."
      tokenizer.get.should == :phrase
      tokenizer.get.should == :comma
      tokenizer.get.should == :initial
      tokenizer.get.should == :eos
    end
    it "should get an initial with a hyphen without a period after the first letter" do
      tokenizer = NameTokenizer.new "Kim, B-J."
      tokenizer.get.should == :phrase
      tokenizer.get.should == :comma
      tokenizer.get.should == :initial
      tokenizer.get.should == :eos
    end
    it "should consider '(eds.)' as an 'initial'" do
      tokenizer = NameTokenizer.new "Ward, P.S. (eds). Ants."
      tokenizer.get.should == :phrase
      tokenizer.get.should == :comma
      tokenizer.get.should == :initial
      tokenizer.get.should == :initial
      tokenizer.get.should == :initial
      tokenizer.get.should == :period
      tokenizer.get.should == :phrase
      tokenizer.get.should == :period
    end
  end

  describe "prepositions" do
    ['da', 'de', 'di', 'del', 'do'].each do |preposition|
      it "should consider the preposition '#{preposition}' at the end of a name as an initial" do
        tokenizer = NameTokenizer.new "Silva, R. R. #{preposition}"
        tokenizer.get.should == :phrase
        tokenizer.get.should == :comma
        tokenizer.get.should == :initial
        tokenizer.get.should == :initial
        tokenizer.get.should == :initial
        tokenizer.get.should == :eos
      end
      it "should consider a preposition in a phrase as part of the phrase" do
        tokenizer = NameTokenizer.new "#{preposition} Silva #{preposition}, R. R."
        tokenizer.get.should == :phrase
        tokenizer.get.should == :comma
        tokenizer.get.should == :initial
        tokenizer.get.should == :initial
        tokenizer.get.should == :eos
      end
    end
  end
end
