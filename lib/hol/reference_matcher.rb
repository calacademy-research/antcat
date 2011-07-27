class Hol::ReferenceMatcher < ReferenceMatcher

  def match target_reference
    matches = super
    return unless matches.present?
    return :no_entries_for_author if matches.first[:status] == :no_entries_for_author
    matches
  end

  def read_references target
    @bibliography ||= Hol::Bibliography.new
    @bibliography.read_references target.principal_author_last_name
  end

  def possible_match? target, candidate
    true
  end
end
