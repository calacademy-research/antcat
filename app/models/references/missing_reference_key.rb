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

  def document_link; end

  def goto_reference_link; end

end
