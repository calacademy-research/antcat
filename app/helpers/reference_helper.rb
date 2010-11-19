module ReferenceHelper
  def format_reference reference
    ReferenceFormatter.format reference
  end

  def italicize string
    ReferenceFormatter.italicize string
  end
end
