class ReferenceMatcher
  def match target
    matches = candidates_for(target).inject([]) do |matches, candidate|
      similarity = target <=> candidate
      matches << {:target => target.id, :match => candidate.id, :similarity => similarity} if similarity > 0
      matches
    end || []
    max_similarity = matches.map {|e| e[:similarity]}.max || 0
    matches = matches.select {|match| match[:similarity] == max_similarity}
    {:similarity => max_similarity, :matches => matches}
  end

  private
  def candidates_for target
    if target.author != @target_author
      @target_author = target.author
      @candidates = ::Reference.with_principal_author_last_name @target_author
    end
    @candidates
  end
end

