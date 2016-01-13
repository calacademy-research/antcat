class ReferenceKey
  def initialize reference
    @reference = reference
  end

  def to_s
    @reference.decorate.format_author_last_names
  end

  def to_link options = {}
    @reference.decorate.to_link options
  end

  def document_link
    @reference.decorate.format_reference_document_link
  end

  def goto_reference_link
    @reference.decorate.goto_reference_link
  end
end
