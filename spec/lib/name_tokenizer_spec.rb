require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe NameTokenizer do

  describe "getting a token" do
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

    it "should get commas" do
      tokenizer = NameTokenizer.new "Wilden, Mark"
      tokenizer.get.should == :phrase
      tokenizer.get.should == :comma
      tokenizer.get.should == :phrase
      tokenizer.get.should == :eos
    end

    it "should get periods" do
      tokenizer = NameTokenizer.new "Wilden."
      tokenizer.get.should == :phrase
      tokenizer.get.should == :period
      tokenizer.get.should == :eos
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

    it "should get a semicolon" do
      tokenizer = NameTokenizer.new "Wilden; Ward"
      tokenizer.get.should == :phrase
      tokenizer.get.should == :semicolon
      tokenizer.get.should == :phrase
      tokenizer.get.should == :eos
    end
  end

  describe "expecting a particular token" do
    it "should advance the cursor after an expectation is fulfilled" do
      tokenizer = NameTokenizer.new "Wilden, Mark"
      tokenizer.expect :phrase
      tokenizer.get.should == :comma
    end

    it "should raise if the expectation is not fulfilled" do
      tokenizer = NameTokenizer.new "Wilden, Mark"
      lambda {tokenizer.expect :comma}.should raise_error NameTokenizer::ExpectationError
    end

    it "should accept alternatives when an array is passed" do
      tokenizer = NameTokenizer.new "Wilden, Mark"
      tokenizer.expect [:phrase, :comma]
      tokenizer.expect [:phrase, :comma]
      tokenizer.expect [:phrase, :comma]
    end
  end

  describe "getting the rest of the string" do
    it "should work" do
      tokenizer = NameTokenizer.new "Wilden, Mark"
      tokenizer.get
      tokenizer.rest.should == ", Mark"
    end
  end

  describe "getting what's been captured" do
    it "should work" do
      tokenizer = NameTokenizer.new "Wilden, Mark"
      tokenizer.get
      tokenizer.captured.should == "Wilden"
    end
    it "should strip trailing whitespace" do
      tokenizer = NameTokenizer.new "Wilden "
      tokenizer.get
      tokenizer.captured.should == "Wilden"
    end
  end

  describe "detecting end of string" do
    it "should know when it's at the end of the string" do
      tokenizer = NameTokenizer.new "Wilden"
      tokenizer.eos?.should be_false
      tokenizer.get
      tokenizer.eos?.should be_true
    end
  end

  describe "skipping over a token" do
    it "should skip over tokens that exist" do
      tokenizer = NameTokenizer.new "M.A. Wilden"
      tokenizer.skip_over(:initial).should be_true
      tokenizer.skip_over(:initial).should be_true
      tokenizer.skip_over(:initial).should be_false
      tokenizer.get.should == :phrase
    end
    it "should just return false if the token doesn't exist" do
      tokenizer = NameTokenizer.new "Wilden"
      tokenizer.skip_over(:initial).should be_false
      tokenizer.get.should == :phrase
    end
    it "should be able to skip over stuff at the end of the string" do
      tokenizer = NameTokenizer.new "Wilden"
      tokenizer.skip_over(:phrase).should be_true
      tokenizer.skip_over(:phrase).should be_false
      tokenizer.get.should == :eos
    end
    it "should skip over alternatives" do
      tokenizer = NameTokenizer.new "Wilden, Mark"
      tokenizer.skip_over([:phrase, :comma]).should be_true
      tokenizer.skip_over([:comma, :phrase]).should be_true
      tokenizer.skip_over([:comma, :period]).should be_false
      tokenizer.skip_over([:phrase]).should be_true
    end
  end

  describe "starting captured" do
    it "should work when called on a string the first time" do
      tokenizer = NameTokenizer.new "Wilden"
      tokenizer.start_capturing
      tokenizer.get
      tokenizer.captured.should == 'Wilden'
    end
  end
end
