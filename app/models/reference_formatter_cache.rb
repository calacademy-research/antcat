class ReferenceFormatterCache
  include Singleton

  def invalidate reference
    return unless reference.formatted_cache?
    unless reference.new_record?
      set reference, nil, :formatted_cache
      set reference, nil, :inline_citation_cache
    end
    Reference.where("nesting_reference_id = ?", reference.id).each do |nestee|
      self.class.instance.invalidate nestee
    end
  end

  def get reference, field = :formatted_cache
    Reference.find(reference.id).send field
  end

  def set reference, value, field = :formatted_cache
    return value if reference.send(field) == value
    reference.update_column field, value
    value
  end

  def populate reference # is this used outside of specs? #TODO find out
    set reference, reference.decorate.format!, :formatted_cache
    user = User.find_by_email 'sblum@calacademy.org'
    set reference, reference.decorate.format_inline_citation!(user: user), :inline_citation_cache
  end

end
