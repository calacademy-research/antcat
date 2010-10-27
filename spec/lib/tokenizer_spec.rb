require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Tokenizer do

  describe "getting a token" do

    it "should get commas" do
      tokenizer = Tokenizer.new ","
      tokenizer.get.should == :comma
      tokenizer.get.should == :eos
    end

    it "should get periods" do
      tokenizer = Tokenizer.new "."
      tokenizer.get.should == :period
      tokenizer.get.should == :eos
    end

    it "should get a semicolon" do
      tokenizer = Tokenizer.new ";"
      tokenizer.get.should == :semicolon
      tokenizer.get.should == :eos
    end
  end

  describe "expecting a particular token" do
    it "should advance the cursor after an expectation is fulfilled" do
      tokenizer = Tokenizer.new ", ;"
      tokenizer.expect :comma
      tokenizer.get.should == :semicolon
    end

    it "should raise if the expectation is not fulfilled" do
      tokenizer = Tokenizer.new "."
      lambda {tokenizer.expect :comma}.should raise_error Tokenizer::ExpectationError
    end

    it "should accept alternatives when an array is passed" do
      tokenizer = Tokenizer.new ", ."
      tokenizer.expect [:period, :comma]
      tokenizer.expect [:period, :comma]
    end
  end

  describe "getting the rest of the string" do
    it "should work" do
      tokenizer = Tokenizer.new ", ."
      tokenizer.get
      tokenizer.rest.should == "."
    end
  end

  describe "getting what's been captured" do
    it "should work" do
      tokenizer = Tokenizer.new ", ."
      tokenizer.get
      tokenizer.captured.should == ","
    end
    it "should strip trailing whitespace" do
      tokenizer = Tokenizer.new ", "
      tokenizer.get
      tokenizer.captured.should == ","
    end
  end

  describe "detecting end of string" do
    it "should know when it's at the end of the string" do
      tokenizer = Tokenizer.new ","
      tokenizer.eos?.should be_false
      tokenizer.get
      tokenizer.eos?.should be_true
    end
  end

  describe "skipping over a token" do
    it "should skip over tokens that exist" do
      tokenizer = Tokenizer.new "..,"
      tokenizer.skip_over(:period).should be_true
      tokenizer.skip_over(:period).should be_true
      tokenizer.skip_over(:period).should be_false
      tokenizer.get.should == :comma
    end
    it "should just return false if the token doesn't exist" do
      tokenizer = Tokenizer.new ","
      tokenizer.skip_over(:period).should be_false
      tokenizer.get.should == :comma
    end
    it "should be able to skip over stuff at the end of the string" do
      tokenizer = Tokenizer.new ","
      tokenizer.skip_over(:comma).should be_true
      tokenizer.skip_over(:comma).should be_false
      tokenizer.get.should == :eos
    end
    it "should skip over alternatives" do
      tokenizer = Tokenizer.new ", ."
      tokenizer.skip_over([:period, :comma]).should be_true
      tokenizer.skip_over([:period, :comma]).should be_true
      tokenizer.skip_over([:period, :comma]).should be_false
      tokenizer.skip_over([:eos]).should be_true
    end
  end

  describe "starting captured" do
    it "should work when called on a string the first time" do
      tokenizer = Tokenizer.new ",."
      tokenizer.start_capturing
      tokenizer.get
      tokenizer.captured.should == ','
    end
  end
end
