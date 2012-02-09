# coding: UTF-8
class UnknownReference < UnmissingReference

  validates_presence_of :citation

  def strip_newlines_from_text_fields
    citation.gsub! /\n/, ' ' if citation.present?
    super
  end

end
