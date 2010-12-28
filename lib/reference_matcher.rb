class ReferenceMatcher
  def match target
    matches = candidates_for(target).inject([]) do |matches, candidate|
      confidence = target <=> candidate
      matches << {:target => target.id, :match => candidate.id, :confidence => confidence} if confidence > 0
      matches
    end || []
    max_confidence = matches.map {|e| e[:confidence]}.max || 0
    matches = matches.select {|match| match[:confidence] == max_confidence}
    {:confidence => max_confidence, :matches => matches}
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

