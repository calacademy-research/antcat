# coding: UTF-8
class Bolton::ReferenceKey
<<<<<<< HEAD
  def initialize authors_string, year
    @authors = authors_string
    @year = year
=======
  def initialize authors_string, citation_year
    @authors = authors_string
    @citation_year = citation_year
>>>>>>> Bolton::ReferenceKey
  end

  def to_s format
    raise unless format == :db
<<<<<<< HEAD
    return @year unless @authors.present?
=======
    return @citation_year unless @authors.present?
>>>>>>> Bolton::ReferenceKey
    key = @authors.dup
    # remove initials
    key.gsub! /\b[[:upper:]]\./, ''
    # remove commas and ampersand
    key.gsub! /[,&]/, ''
    # collapse spaces
    key.squish!
<<<<<<< HEAD
    key << ' ' << @year
=======
    key << ' ' << @citation_year
>>>>>>> Bolton::ReferenceKey
  end

end
