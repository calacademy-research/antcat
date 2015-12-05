# coding: UTF-8
module Formatters::StatisticsFormatter
  #extend ActionView::Helpers::TagHelper
  #extend ActionView::Helpers::NumberHelper
  #extend Formatters::Formatter

  def self.statistics statistics, options = {}
    taxon.decorate.statistics statistics, options
  end
  
end