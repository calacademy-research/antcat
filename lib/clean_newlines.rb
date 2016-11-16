# TODO extra curricular: create an RSpec matcher for this, eg
# `expect(Citation).to clean_newlines_on :notes_taxt`

module CleanNewlines
  # TODO move to a concern?
  def self.clean_newlines record, *text_attributes
    text_attributes.each do |text_attribute|
      dirty_string = record[text_attribute]
      next if dirty_string.nil? or dirty_string.empty?
      cleaned_string = dirty_string.gsub %r{\r|\n}, ''
      record[text_attribute] = cleaned_string
    end
  end
end
