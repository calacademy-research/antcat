# coding: UTF-8
class ReferenceMatcher

  def match target
    candidates_for(target).inject([]) do |matches, candidate|
      if possible_match? target, candidate
        similarity = target <=> candidate
        matches << {:target => target, :match => candidate, :similarity => similarity} if similarity >= min_similarity
      end
      matches
    end
  end

  def possible_match? target, candidate
    target.id != candidate.id
  end

  def min_similarity
    0.01
  end

  def candidates_for target
    if target.author != @target_author
      @target_author = target.author
      @candidates = read_references @target_author
    end
    @candidates || []
  end

  def read_references target
    ::Reference.with_principal_author_last_name target
  end

end

