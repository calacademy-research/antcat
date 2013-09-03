# coding: UTF-8
module CleanNewlines

  def clean_newlines record, *text_attributes
    for text_attribute in text_attributes
      dirty_string = record[text_attribute]
      next if dirty_string.nil? or dirty_string.empty?
      cleaned_string = dirty_string.gsub %r{\r|\n}, ''
      record[text_attribute] = cleaned_string
    end
  end

end
