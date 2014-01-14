# coding: UTF-8
class FormattedReferenceCache

  def self.get reference, formatted_reference
    return unless reference
    reference.formatted_cache
  end

  def self.set reference, formatted_reference
    return unless reference
    reference.formatted_cache = formatted_reference
    reference.save!
  end

end
