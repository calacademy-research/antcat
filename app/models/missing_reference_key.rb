# coding: UTF-8
class MissingReferenceKey

  def initialize citation
    @citation = citation
  end

  def to_link _user = nil, _options = nil
    @citation.html_safe
  end

  def to_s
    @citation
  end

end
