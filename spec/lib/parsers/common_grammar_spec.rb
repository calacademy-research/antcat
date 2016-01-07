require 'spec_helper'

describe Parsers::CommonGrammar do
  before do
    @parser = Parsers::CommonGrammar
  end

  describe "parsing a year" do
    it "should not consider a five digit number a year" do
      expect {@parser.parse('18345', :root => :year, :consume => false)}.to raise_error Citrus::ParseError
    end
  end

  describe "parsing a blank line" do

    it "should not consider a nonblank line blank" do
      expect {@parser.parse(%{  a  }, :root => :blank_line)}.to raise_error Citrus::ParseError
      expect(@parser.parse(%{  a  }, :root => :nonblank_line).value).to eq(:nonblank_line)
    end

    it "should handle '<p> </p>' (nested empty paragraph)" do
      expect(@parser.parse(%{<p> </p>}, :root => :blank_line).value).to eq(:blank_line)
    end

    it "should handle '<span>.</span>'" do
      expect(@parser.parse('<span>.</span>', :root => :blank_line).value).to eq(:blank_line)
    end

    it "should handle a nonbreaking space inside a subparagraph" do
      expect(@parser.parse(%{<span style="mso-spacerun: yes">&nbsp;</span>}, :root => :blank_line).value).to eq(:blank_line)
    end

    it "should handle a red paragraph w/nonbreaking space" do
      expect(@parser.parse(%{<span style="color:red"><p> </p></span>}, :root => :blank_line).value).to eq(:blank_line)
    end

    it "should handle a single period" do
      expect(@parser.parse(%{.}, :root => :blank_line).value).to eq(:blank_line)
    end

    it "should handle a bold empty paragraph" do
      expect(@parser.parse(%{<b><p> </p></b>}, :root => :blank_line).value).to eq(:blank_line)
    end
    it "should handle another bold empty paragraph" do
      expect(@parser.parse(%{<b style="mso-bidi-font-weight:normal"><span lang="EN-GB"><p> </p></span></b>}, :root => :blank_line).value).to eq(:blank_line)
    end

    it "should handle an italic space" do
      expect(@parser.parse(%{<i> </i>}, :root => :blank_line).value).to eq(:blank_line)
    end

    it "should handle a nonbreaking space inside a subparagraph" do
      expect(@parser.parse(%{<p> </p>}, :root => :blank_line).value).to eq(:blank_line)
    end
    it "should handle a nonbreaking space" do
      expect(@parser.parse(%{ }, :root => :blank_line).value).to eq(:blank_line)
    end
    it "should handle a spacerun" do
      expect(@parser.parse(%{<span style="mso-spacerun: yes"> </span>}, :root => :blank_line).value).to eq(:blank_line)
    end
    it "should handle an empty paragraph with a font" do
      expect(@parser.parse(%{<span style='font-family:"Times New Roman"'><p> </p></span>}, :root => :blank_line).value).to eq(:blank_line)
    end
    it "should handle an empty paragraph with italics" do
      expect(@parser.parse(%{<i><p> </p></i>}, :root => :blank_line).value).to eq(:blank_line)
    end
    it "should handle a blank bold red paragraph" do
      expect(@parser.parse(%{<b><span style="color:red"><p> </p></span></b>}, :root => :blank_line).value).to eq(:blank_line)
    end
    it "should handle a namespaced paragraph with a blank" do
      expect(@parser.parse(%{<o:p>&nbsp;</o:p>}, :root => :blank_line).value).to eq(:blank_line)
    end
    it "should handle a nonbreaking space inside paragraph" do
      expect(@parser.parse(%{<p>&nbsp;</p>}, :root => :blank_line).value).to eq(:blank_line)
    end
    it "should handle an empty span" do
      expect(@parser.parse(%{<span lang="EN-GB"> </span>}, :root => :space)).not_to be_nil
    end
    it "should just ignore this span as space" do
      expect(@parser.parse(%{<span lang="EN-GB">}, :root => :space)).not_to be_nil
    end
    it "should just ignore this span as space" do
      expect(@parser.parse(%{<span lang=EN-GB>}, :root => :space)).not_to be_nil
    end
    it "should just ignore this span around an empty paragraph as a blank line" do
      expect(@parser.parse(%{<span lang="EN-GB"><p> </p></span>}, :root => :blank_line)).not_to be_nil
    end

  end

  describe "Uppercase and capitalized words" do

    it "should differentiate between a capitalized word and an uppercase word" do
      expect {@parser.parse(%{Abc}, :root => :uppercase_word)}.to raise_error
      expect(@parser.parse(%{Abc}, :root => :capitalized_word)).not_to be_nil
      expect(@parser.parse(%{ABC}, :root => :uppercase_word)).not_to be_nil
      expect {@parser.parse(%{ABC}, :root => :capitalized_word)}.to raise_error
    end

    it "should only consider them words if they are followed by word break" do
      expect(@parser.parse(%{ABC}, :root => :uppercase_word)).not_to be_nil
      expect {@parser.parse(%{Abc}, :root => :uppercase_word)}.to raise_error
    end

    it "should not include the word break in the parsed value" do
      expect {@parser.parse("Abc)", :root => :uppercase_word)}.to raise_error
    end

    it "should not consider a single letter an uppercase or capitalized word" do
      expect {@parser.parse(%{B}, :root => :uppercase_word)}.to raise_error
      expect {@parser.parse(%{B}, :root => :capitalized_word)}.to raise_error
    end

    it "should consider A an uppercase or capitalized word" do
      expect {@parser.parse(%{A}, :root => :uppercase_word)}.not_to raise_error
      expect {@parser.parse(%{A}, :root => :capitalized_word)}.not_to raise_error
    end

    it "should consider AN/An an uppercase or capitalized word" do
      expect {@parser.parse(%{AN}, :root => :uppercase_word)}.not_to raise_error
      expect {@parser.parse(%{An}, :root => :capitalized_word)}.not_to raise_error
    end

  end

  describe "Uppercase line" do
    it "should be a string that's all uppercase" do
      expect(@parser.parse(%{ABC}, :root => :uppercase_line)).not_to be_nil
    end
    it "should not be a string that's not all uppercase" do
      expect {@parser.parse(%{ABC bcd}, :consume => false, :root => :uppercase_line)}.to raise_error
    end
  end

  describe "Closing tags" do

    it "should be strict, if the close_tags_required rule is used" do
      expect {@parser.parse(%{ }, :root => :close_tags_required)}.to raise_error
      expect(@parser.parse(%{</p>}, :root => :close_tags_required)).not_to be_nil
      expect(@parser.parse(%{ </p> }, :root => :close_tags_required)).not_to be_nil
      expect(@parser.parse(%{ </p> </i> }, :root => :close_tags_required)).not_to be_nil
    end

    it "should be loose" do
      expect {@parser.parse(%{ }, :root => :close_tags)}.not_to raise_error
      expect(@parser.parse(%{</p>}, :root => :close_tags)).not_to be_nil
      expect(@parser.parse(%{ </p> }, :root => :close_tags)).not_to be_nil
      expect(@parser.parse(%{ </p> </i> }, :root => :close_tags)).not_to be_nil
    end

  end

  describe "Color" do

    it "shouldn't slop over" do
      expect(@parser.parse(%{<span style="color:}, :root => :start_color_span_start)).not_to be_nil
      expect {@parser.parse(%{<span> <span style="color:}, :root => :start_color_span_start)}.to raise_error
    end

    describe "purple" do
      it "should recognize purple" do
        expect(Parsers::CommonGrammar.parse(%{<span style="color:purple">}, :root => :purple)).not_to be_nil
      end
      it "should recognize purple" do
        expect(Parsers::CommonGrammar.parse(%{<span style="color:#6600CC">}, :root => :purple)).not_to be_nil
      end
    end

    describe "brown" do
      it "should recognize brown" do
        expect(Parsers::CommonGrammar.parse(%{<span style="color:#663300">}, :root => :brown)).not_to be_nil
      end
      it "should recognize brown" do
        expect(Parsers::CommonGrammar.parse(%{<span style="color:#984806">}, :root => :brown)).not_to be_nil
      end
    end
  end

  it "should recognize a bracketed phrase" do
    expect(@parser.parse('[a phrase]', :root => :bracketed_phrase)).not_to be_nil
  end

  it "should recognize a parenthesized phrase and return its contents" do
    expect(@parser.parse('(a phrase)', :root => :parenthesized_phrase).value).to eq('a phrase')
  end

  it "should recognize et al." do
    @parser.parse('<i>et al.</i>', :root => :et_al)
  end

  it "should recognize recte" do
    @parser.parse('<i>recte</i>', :root => :recte)
  end

  it "should recognize sic" do
    @parser.parse('<i>sic</i>', :root => :sic)
  end

end
