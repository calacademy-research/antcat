require 'spec_helper'

class FormattersAdvancedSearchFormatterTestClass
  include Formatters::AdvancedSearchFormatter
end

describe Formatters::AdvancedSearchFormatter do
  let(:formatter) { FormattersAdvancedSearchFormatterTestClass.new }

  describe "#format_type_localities" do
    it "doesn't crash (regression)" do
      taxon = create_genus verbatim_type_locality: 'Verbatim type locality'
      formatter.format_type_localities taxon
    end
  end
end
