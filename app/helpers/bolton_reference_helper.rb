# coding: UTF-8
module BoltonReferenceHelper
  def color_for_bolton_reference bolton_reference
    {nil => 'lightpink', 'auto' => 'lightgreen', 'manual' => 'darkgreen'}[bolton_reference.match_type]
  end

  def italicize string
    ReferenceFormatter.italicize string
  end

  def format_timestamp timestamp
    ReferenceFormatter.format_timestamp timestamp
  end
end
