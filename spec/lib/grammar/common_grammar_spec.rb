# coding: UTF-8
require 'spec_helper'

describe CommonGrammar do
  describe "parsing text" do

    it "should recognize text" do
      CommonGrammar.parse(%{  a  }, root: :text).value.should_not be_nil
      lambda {CommonGrammar.parse(%{  <a>  }, root: :text)}.should raise_error Citrus::ParseError
      lambda {CommonGrammar.parse(%{  .  }, root: :text)}.should raise_error Citrus::ParseError
    end

  end

  describe "parsing a blank line" do

    it "should not consider a nonblank line blank" do
      lambda {CommonGrammar.parse(%{  a  }, root: :blank_line)}.should raise_error Citrus::ParseError
      CommonGrammar.parse(%{  a  }, root: :nonblank_line).value.should == :nonblank_line
    end

    it "should handle '<p> </p>' (nested empty paragraph)" do
      CommonGrammar.parse(%{<p> </p>}, root: :blank_line).value.should == :blank_line
    end

    it "should handle a nonbreaking space inside a subparagraph" do
      CommonGrammar.parse(%{<span style="mso-spacerun: yes">&nbsp;</span>}, root: :blank_line).value.should == :blank_line
    end

    it "should handle a red paragraph w/nonbreaking space" do
      CommonGrammar.parse(%{<span style="color:red"><p> </p></span>}, root: :blank_line).value.should == :blank_line
    end

    it "should handle a single period" do
      CommonGrammar.parse(%{.}, root: :blank_line).value.should == :blank_line
    end

    it "should handle a bold empty paragraph" do
      CommonGrammar.parse(%{<b><p> </p></b>}, root: :blank_line).value.should == :blank_line
    end
    it "should handle another bold empty paragraph" do
      CommonGrammar.parse(%{<b style="mso-bidi-font-weight:normal"><span lang="EN-GB"><p> </p></span></b>}, root: :blank_line).value.should == :blank_line
    end

    it "should handle an italic space" do
      CommonGrammar.parse(%{<i> </i>}, root: :blank_line).value.should == :blank_line
    end

    it "should handle a nonbreaking space inside a subparagraph" do
      CommonGrammar.parse(%{<p> </p>}, root: :blank_line).value.should == :blank_line
    end
    it "should handle a nonbreaking space" do
      CommonGrammar.parse(%{ }, root: :blank_line).value.should == :blank_line
    end
    it "should handle a spacerun" do
      CommonGrammar.parse(%{<span style="mso-spacerun: yes"> </span>}, root: :blank_line).value.should == :blank_line
    end
    it "should handle an empty paragraph with a font" do
      CommonGrammar.parse(%{<span style='font-family:"Times New Roman"'><p> </p></span>}, root: :blank_line).value.should == :blank_line
    end
    it "should handle an empty paragraph with italics" do
      CommonGrammar.parse(%{<i><p> </p></i>}, root: :blank_line).value.should == :blank_line
    end
    it "should handle a blank bold red paragraph" do
      CommonGrammar.parse(%{<b><span style="color:red"><p> </p></span></b>}, root: :blank_line).value.should == :blank_line
    end
    it "should handle a namespaced paragraph with a blank" do
      CommonGrammar.parse(%{<o:p>&nbsp;</o:p>}, root: :blank_line).value.should == :blank_line
    end
    it "should handle a nonbreaking space inside paragraph" do
      CommonGrammar.parse(%{<p>&nbsp;</p>}, root: :blank_line).value.should == :blank_line
    end
    it "should handle an empty span" do
      CommonGrammar.parse(%{<span lang="EN-GB"> </span>}, root: :space).should_not be_nil
    end
    it "should just ignore this span as space" do
      CommonGrammar.parse(%{<span lang="EN-GB">}, root: :space).should_not be_nil
    end
    it "should just ignore this span as space" do
      CommonGrammar.parse(%{<span lang=EN-GB>}, root: :space).should_not be_nil
    end
    it "should just ignore this span around an empty paragraph as a blank line" do
      CommonGrammar.parse(%{<span lang="EN-GB"><p> </p></span>}, root: :blank_line).should_not be_nil
    end

  end

  describe "Uppercase and capitalized words" do

    it "should differentiate between a capitalized word and an uppercase word" do
      lambda {CommonGrammar.parse(%{Abc}, root: :uppercase_word)}.should raise_error
      CommonGrammar.parse(%{Abc}, root: :capitalized_word).should_not be_nil
      CommonGrammar.parse(%{ABC}, root: :uppercase_word).should_not be_nil
      lambda {CommonGrammar.parse(%{ABC}, root: :capitalized_word)}.should raise_error
    end

    it "should only consider them words if they are followed by word break" do
      CommonGrammar.parse(%{ABC}, root: :uppercase_word).should_not be_nil
      lambda {CommonGrammar.parse(%{Abc}, root: :uppercase_word)}.should raise_error
    end

    it "should not consider a single letter an uppercase or capitalized word" do
      lambda {CommonGrammar.parse(%{A}, root: :uppercase_word)}.should raise_error
      lambda {CommonGrammar.parse(%{A}, root: :capitalized_word)}.should raise_error
    end

  end

  describe "Closing tags" do

    it "should be strict, if the close_tags_required rule is used" do
      lambda {CommonGrammar.parse(%{ }, root: :close_tags_required)}.should raise_error
      CommonGrammar.parse(%{</p>}, root: :close_tags_required).should_not be_nil 
      CommonGrammar.parse(%{ </p> }, root: :close_tags_required).should_not be_nil 
      CommonGrammar.parse(%{ </p> </i> }, root: :close_tags_required).should_not be_nil 
    end

    it "should be loose" do
      lambda {CommonGrammar.parse(%{ }, root: :close_tags)}.should_not raise_error
      CommonGrammar.parse(%{</p>}, root: :close_tags).should_not be_nil 
      CommonGrammar.parse(%{ </p> }, root: :close_tags).should_not be_nil 
      CommonGrammar.parse(%{ </p> </i> }, root: :close_tags).should_not be_nil 
    end

  end

  describe "Color" do

    it "shouldn't slop over" do
      CommonGrammar.parse(%{<span style="color:}, root: :start_color_span_start).should_not be_nil
      lambda {CommonGrammar.parse(%{<span> <span style="color:}, root: :start_color_span_start)}.should raise_error
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

  describe "Species name" do

    it "should allow a lowercase word" do
      CommonGrammar.parse('chilensis', root: :species_name).should_not be_nil
    end
    it "should not allow a space" do
      lambda {CommonGrammar.parse('chilensis negrescens', root: :species_name)}.should raise_error
    end
    it "should allow a hyphen in the second position" do
      CommonGrammar.parse('v-nigra', root: :species_name).should_not be_nil
    end
    it "should not allow a hyphen in the first position" do
      lambda {CommonGrammar.parse('-vnigra', root: :species_name)}.should raise_error
    end
    it "should not allow a hyphen in the third position" do
      lambda {CommonGrammar.parse('vn-igra', root: :species_name)}.should raise_error
    end
    it "can have only two letters" do
      CommonGrammar.parse('io', root: :species_name).should_not be_nil
    end

  end

  describe "Space" do
    it "should consider this span space" do
      CommonGrammar.parse(%{<span style="font-size:11.0pt;mso-bidi-font-size: 10.0pt">}, root: :space).should_not be_nil
    end
  end
end
