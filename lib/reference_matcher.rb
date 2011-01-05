class ReferenceMatcher
  def match target
    candidates_for(target).inject([]) do |matches, candidate|
      if possible_match? target, candidate
        similarity = target <=> candidate
        matches << {:target => target.id, :match => candidate.id, :similarity => similarity} if similarity > 0
      end
      matches
    end || []
  end

  private
  def possible_match? target, candidate
    true
  end

  def candidates_for target
    if target.author != @target_author
      @target_author = target.author
      @candidates = ::Reference.with_principal_author_last_name @target_author
    end
    @candidates
  end
end

