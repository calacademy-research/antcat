# coding: UTF-8
class DuplicateReference < ActiveRecord::Base
  belongs_to :reference
  belongs_to :duplicate, :class_name => 'Reference'

  def resolve
    original, copy = pick_original_and_copy
    DuplicateReference.merge original.id, copy.id
  end

  def self.merge good_id, bad_id
    transaction do
      NestedReference.all(:conditions => ['nested_reference_id = ?', bad_id]).each do |reference|
        reference.update_attributes :nested_reference_id => good_id
      end
      Reference.find(bad_id).destroy
    end
  end

  def to_s
    "#{ReferenceFormatter.format(reference)}\n#{ReferenceFormatter.format(duplicate)}"
  end

  def show_resolution
    puts self
    original, copy = pick_original_and_copy
    puts "Original: #{ReferenceFormatter.format(original)}"
  end

  private
  def pick_original_and_copy
    result = nil
    return result if result = pick {|reference| reference.public_notes.present?}
    return result if result = pick {|reference| reference.editor_notes.present?}
    return result if result = pick {|reference| reference.taxonomic_notes.present?}
    return result if result = pick {|reference| reference.cite_code.present?}
    return result if result = pick {|reference| reference.possess.present?}
    return result if result = pick {|reference| reference.date.present?}
    return result if result = pick {|reference| reference.citation_year =~ /\D/}
    raise StandardError.new "#{id} (#{similarity}): Couldn't decide which of\n#{reference.id} #{ReferenceFormatter.format(reference)}\nand\n#{duplicate.id} #{ReferenceFormatter.format(duplicate)}\nis the good one"
  end

  def pick
    return [reference, duplicate] if yield reference
    return [duplicate, reference] if yield duplicate
  end
end
