# coding: UTF-8
class MissingReferenceKey

  def initialize citation
    @citation = citation
  end

  def to_link _ = nil
    @citation.html_safe
  end

  def to_s
    @citation
  end

end
