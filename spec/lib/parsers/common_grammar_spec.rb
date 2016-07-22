require 'spec_helper'

Citrus.load "#{Rails.root.join}/lib/parsers/common_grammar"

describe "Parsers::CommonGrammar" do
  before do
    @parser = Parsers::CommonGrammar
  end

  describe "parsing a year" do
    it "should not consider a five digit number a year" do
      expect { @parser.parse('18345', root: :year, consume: false) }.to raise_error Citrus::ParseError
    end
  end

  it "should recognize et al." do
    @parser.parse '<i>et al.</i>', root: :et_al
  end

end
