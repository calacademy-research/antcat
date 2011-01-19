class UnknownReference < Reference

  validates_presence_of :citation
  before_validation :strip_newlines

  def strip_newlines
    citation.gsub! /\n/, ' ' if citation.present?
    super
  end

end
