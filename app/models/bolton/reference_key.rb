# coding: UTF-8
class Bolton::ReferenceKey

  def initialize authors_string, citation_year
    @authors = authors_string
    @citation_year = citation_year
  end

  def to_s format
    raise unless format == :db
    return @citation_year unless @authors.present?
    key = @authors.dup
    # remove initials
    key.gsub! /\b[[:upper:]]\./, ''
    # remove commas and ampersand
    key.gsub! /[,&]/, ''
    # collapse spaces
    key.squish!
    key << ' ' << @citation_year if @citation_year
  end

end
