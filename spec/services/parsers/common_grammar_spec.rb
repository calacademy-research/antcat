require 'spec_helper'

Citrus.load "#{Rails.root.join}/app/services/parsers/common_grammar"

describe Parsers::CommonGrammar do
  before do
    @parser = Parsers::CommonGrammar
  end

  describe "parsing a year" do
    it "doesn't consider a five digit number a year" do
      expect { @parser.parse('18345', root: :year, consume: false) }
        .to raise_error Citrus::ParseError
    end
  end

  it "recognizes et al." do
    @parser.parse '<i>et al.</i>', root: :et_al
  end
end
