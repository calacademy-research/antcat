# coding: UTF-8
class ReferenceFormatterCache
  include Singleton

  def invalidate reference
    return unless reference.formatted_cache?
    set reference, nil unless reference.new_record?
    Reference.where("nested_reference_id = ?", reference.id).each do |nestee|
      nestee.invalidate_formatted_reference_cache
    end
  end

  def get reference
    Reference.find(reference.id).formatted_cache
  end

  def set reference, value
    reference.update_column :formatted_cache, value
  end

  def populate reference
    value = Formatters::ReferenceFormatter.format reference, false
    set reference, value
    value
  end

end
