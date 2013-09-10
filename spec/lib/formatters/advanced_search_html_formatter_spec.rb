# coding: UTF-8
require 'spec_helper'

class FormattersAdvancedSearchHtmlFormatterTestClass
  include Formatters::AdvancedSearchHtmlFormatter
end

describe Formatters::AdvancedSearchFormatter do
  before do
    @formatter = FormattersAdvancedSearchHtmlFormatterTestClass.new
  end

  describe "Formatting search results" do
    it "should know how to do it" do
    end
  end
end

