# coding: UTF-8
require 'spec_helper'

describe @parser do
  before do
    @parser = CommonGrammar
  end

  describe "parsing a year" do
    it "should not consider a five digit number a year" do
      lambda {@parser.parse('18345', root: :year, consume: false)}.should raise_error Citrus::ParseError
    end
  end

  describe "parsing a blank line" do

    it "should not consider a nonblank line blank" do
      lambda {@parser.parse(%{  a  }, root: :blank_line)}.should raise_error Citrus::ParseError
      @parser.parse(%{  a  }, root: :nonblank_line).value.should == :nonblank_line
    end

    it "should handle '<p> </p>' (nested empty paragraph)" do
      @parser.parse(%{<p> </p>}, root: :blank_line).value.should == :blank_line
    end

    it "should handle '<span>.</span>'" do
      @parser.parse('<span>.</span>', root: :blank_line).value.should == :blank_line
    end

    it "should handle a nonbreaking space inside a subparagraph" do
      @parser.parse(%{<span style="mso-spacerun: yes">&nbsp;</span>}, root: :blank_line).value.should == :blank_line
    end

    it "should handle a red paragraph w/nonbreaking space" do
      @parser.parse(%{<span style="color:red"><p> </p></span>}, root: :blank_line).value.should == :blank_line
    end

    it "should handle a single period" do
      @parser.parse(%{.}, root: :blank_line).value.should == :blank_line
    end

    it "should handle a bold empty paragraph" do
      @parser.parse(%{<b><p> </p></b>}, root: :blank_line).value.should == :blank_line
    end
    it "should handle another bold empty paragraph" do
      @parser.parse(%{<b style="mso-bidi-font-weight:normal"><span lang="EN-GB"><p> </p></span></b>}, root: :blank_line).value.should == :blank_line
    end

    it "should handle an italic space" do
      @parser.parse(%{<i> </i>}, root: :blank_line).value.should == :blank_line
    end

    it "should handle a nonbreaking space inside a subparagraph" do
      @parser.parse(%{<p> </p>}, root: :blank_line).value.should == :blank_line
    end
    it "should handle a nonbreaking space" do
      @parser.parse(%{ }, root: :blank_line).value.should == :blank_line
    end
    it "should handle a spacerun" do
      @parser.parse(%{<span style="mso-spacerun: yes"> </span>}, root: :blank_line).value.should == :blank_line
    end
    it "should handle an empty paragraph with a font" do
      @parser.parse(%{<span style='font-family:"Times New Roman"'><p> </p></span>}, root: :blank_line).value.should == :blank_line
    end
    it "should handle an empty paragraph with italics" do
      @parser.parse(%{<i><p> </p></i>}, root: :blank_line).value.should == :blank_line
    end
    it "should handle a blank bold red paragraph" do
      @parser.parse(%{<b><span style="color:red"><p> </p></span></b>}, root: :blank_line).value.should == :blank_line
    end
    it "should handle a namespaced paragraph with a blank" do
      @parser.parse(%{<o:p>&nbsp;</o:p>}, root: :blank_line).value.should == :blank_line
    end
    it "should handle a nonbreaking space inside paragraph" do
      @parser.parse(%{<p>&nbsp;</p>}, root: :blank_line).value.should == :blank_line
    end
    it "should handle an empty span" do
      @parser.parse(%{<span lang="EN-GB"> </span>}, root: :space).should_not be_nil
    end
    it "should just ignore this span as space" do
      @parser.parse(%{<span lang="EN-GB">}, root: :space).should_not be_nil
    end
    it "should just ignore this span as space" do
      @parser.parse(%{<span lang=EN-GB>}, root: :space).should_not be_nil
    end
    it "should just ignore this span around an empty paragraph as a blank line" do
      @parser.parse(%{<span lang="EN-GB"><p> </p></span>}, root: :blank_line).should_not be_nil
    end

  end

  describe "Uppercase and capitalized words" do

    it "should differentiate between a capitalized word and an uppercase word" do
      lambda {@parser.parse(%{Abc}, root: :uppercase_word)}.should raise_error
      @parser.parse(%{Abc}, root: :capitalized_word).should_not be_nil
      @parser.parse(%{ABC}, root: :uppercase_word).should_not be_nil
      lambda {@parser.parse(%{ABC}, root: :capitalized_word)}.should raise_error
    end

    it "should only consider them words if they are followed by word break" do
      @parser.parse(%{ABC}, root: :uppercase_word).should_not be_nil
      lambda {@parser.parse(%{Abc}, root: :uppercase_word)}.should raise_error
    end

    it "should not include the word break in the parsed value" do
      lambda {@parser.parse("Abc)", root: :uppercase_word)}.should raise_error
    end

    it "should not consider a single letter an uppercase or capitalized word" do
      lambda {@parser.parse(%{B}, root: :uppercase_word)}.should raise_error
      lambda {@parser.parse(%{B}, root: :capitalized_word)}.should raise_error
    end

    it "should consider A an uppercase or capitalized word" do
      lambda {@parser.parse(%{A}, root: :uppercase_word)}.should_not raise_error
      lambda {@parser.parse(%{A}, root: :capitalized_word)}.should_not raise_error
    end

    it "should consider AN/An an uppercase or capitalized word" do
      lambda {@parser.parse(%{AN}, root: :uppercase_word)}.should_not raise_error
      lambda {@parser.parse(%{An}, root: :capitalized_word)}.should_not raise_error
    end

  end

  describe "Uppercase line" do
    it "should be a string that's all uppercase" do
      @parser.parse(%{ABC}, root: :uppercase_line).should_not be_nil
    end
    it "should not be a string that's not all uppercase" do
      lambda {@parser.parse(%{ABC bcd}, consume: false, root: :uppercase_line)}.should raise_error
    end
  end

  describe "Closing tags" do

    it "should be strict, if the close_tags_required rule is used" do
      lambda {@parser.parse(%{ }, root: :close_tags_required)}.should raise_error
      @parser.parse(%{</p>}, root: :close_tags_required).should_not be_nil 
      @parser.parse(%{ </p> }, root: :close_tags_required).should_not be_nil 
      @parser.parse(%{ </p> </i> }, root: :close_tags_required).should_not be_nil 
    end

    it "should be loose" do
      lambda {@parser.parse(%{ }, root: :close_tags)}.should_not raise_error
      @parser.parse(%{</p>}, root: :close_tags).should_not be_nil 
      @parser.parse(%{ </p> }, root: :close_tags).should_not be_nil 
      @parser.parse(%{ </p> </i> }, root: :close_tags).should_not be_nil 
    end

  end

  describe "Color" do

    it "shouldn't slop over" do
      @parser.parse(%{<span style="color:}, root: :start_color_span_start).should_not be_nil
      lambda {@parser.parse(%{<span> <span style="color:}, root: :start_color_span_start)}.should raise_error
    end

    describe "purple" do
      it "should recognize purple" do
        CommonGrammar.parse(%{<span style="color:purple">}, root: :purple).should_not be_nil
      end
      it "should recognize purple" do
        CommonGrammar.parse(%{<span style="color:#6600CC">}, root: :purple).should_not be_nil
      end
    end

    describe "brown" do
      it "should recognize brown" do
        CommonGrammar.parse(%{<span style="color:#663300">}, root: :brown).should_not be_nil
      end
      it "should recognize brown" do
        CommonGrammar.parse(%{<span style="color:#984806">}, root: :brown).should_not be_nil
      end
    end
  end

  it "should recognize a bracketed phrase" do
    @parser.parse('[a phrase]', root: :bracketed_phrase).should_not be_nil
  end

  it "should recognize a parenthesized phrase and return its contents" do
    @parser.parse('(a phrase)', root: :parenthesized_phrase).value.should == 'a phrase'
  end

  it "should recognize et al." do
    @parser.parse('<i>et al.</i>', root: :et_al)
  end

  it "should recognize recte" do
    @parser.parse('<i>recte</i>', root: :recte)
  end

  it "should recognize sic" do
    @parser.parse('<i>sic</i>', root: :sic)
  end

end
