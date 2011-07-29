class Hol::ReferenceMatcher < ReferenceMatcher

  def match target_reference
    matches = super
    return :no_entries_for_author if @no_entries_for_author
    return unless matches.present?
    matches
  end

  def read_references target
    @bibliography ||= Hol::Bibliography.new
    result = @bibliography.read_references target
    @no_entries_for_author = result.blank?
    result
  end

  def possible_match? target, candidate
    true
  end
end
