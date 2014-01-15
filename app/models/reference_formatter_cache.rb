# coding: UTF-8
class ReferenceFormatterCache
  include Singleton
  def invalidate reference
    return unless reference.formatted_cache?
    reference.update_column :formatted_cache, nil unless reference.new_record?
    Reference.where("nested_reference_id = ?", reference.id).each do |nestee|
      nestee.invalidate_formatted_reference_cache
    end
  end
end
