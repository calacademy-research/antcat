# coding: UTF-8
class Importers::Bolton::Bibliography::ReferenceFormatter
  include ERB::Util

  def self.format reference, format = :html
    new(reference, format).format
  end

  def initialize reference, format
    @reference = reference
    @format = format
  end

  def format
    s = ''
    s << @reference.original
    s << " (#{@reference.reference_type.gsub(/Reference/, '')})"
    s << " #{@reference.id}"
    s
  end

end
