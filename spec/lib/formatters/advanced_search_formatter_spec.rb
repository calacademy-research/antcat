require 'spec_helper'

class FormattersAdvancedSearchFormatterTestClass
  include Formatters::AdvancedSearchFormatter
end

describe Formatters::AdvancedSearchFormatter do
  subject(:formatter) { FormattersAdvancedSearchFormatterTestClass.new }

  describe "#format_type_localities" do
    let(:taxon) { create :genus }

    it "doesn't crash (regression)" do
      formatter.format_type_localities taxon
    end
  end
end
