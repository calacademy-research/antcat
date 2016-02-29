# coding: UTF-8
require 'spec_helper'

class FormattersAdvancedSearchFormatterTestClass
  include Formatters::AdvancedSearchFormatter
end

describe Formatters::AdvancedSearchFormatter do
  before do
    @formatter = FormattersAdvancedSearchFormatterTestClass.new
  end

  describe "Formatting type localities (regression)" do
    it "should not crash" do
      taxon = create_genus verbatim_type_locality: 'Verbatim type locality'
      @formatter.format_type_localities taxon
    end
  end
end
