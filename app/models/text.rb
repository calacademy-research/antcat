# coding: UTF-8
class Text < ActiveRecord::Base
  has_and_belongs_to_many :references

  def self.import parse_result
    marked_up_text = ''
    references = []
    parse_result.each do |parse_result_item|
      if parse_result_item[:phrase]
        marked_up_text << parse_result_item[:phrase]
        marked_up_text << parse_result_item[:delimiter] if parse_result_item[:delimiter]
      elsif parse_result_item[:author_names]
        reference = Reference.find_by_authors_and_year parse_result_item[:author_names], parse_result_item[:year]
        raise "Couldn't find reference" unless reference
        references << reference
        marked_up_text << "<reference #{reference.id}>"
        marked_up_text << ': ' << parse_result_item[:pages] if parse_result_item[:pages]
        marked_up_text << parse_result_item[:delimiter] if parse_result_item[:delimiter]
      end
    end
    text = Text.create! :marked_up_text => marked_up_text
    text.references = references
  end
end
