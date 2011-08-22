# coding: UTF-8
module ReferenceHelper
  def format_reference reference
    ReferenceFormatter.format reference
  end

  def italicize string
    ReferenceFormatter.italicize string
  end

  def format_timestamp timestamp
    ReferenceFormatter.format_timestamp timestamp
  end
end
