# coding: UTF-8
class FormattedReferenceCache
  def self.cache reference, formatted_reference
    reference.formatted_cache = formatted_reference
    reference.save!
  end
end
