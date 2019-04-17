require 'spec_helper'

Citrus.load "#{Rails.root.join}/app/services/parsers/common_grammar"

describe Parsers::CommonGrammar do
  subject(:parser) { described_class }

  it "recognizes et al." do
    parser.parse '<i>et al.</i>', root: :et_al
  end
end
