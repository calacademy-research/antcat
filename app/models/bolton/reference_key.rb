# coding: UTF-8
class Bolton::ReferenceKey
  def initialize authors_string, year
    @authors = authors_string
    @year = year
  end

  def to_s format
    raise unless format == :db
    return @year unless @authors.present?
    key = @authors.dup
    # remove initials
    key.gsub! /\b[[:upper:]]\./, ''
    # remove commas and ampersand
    key.gsub! /[,&]/, ''
    # collapse spaces
    key.squish!
    key << ' ' << @year
  end

end
