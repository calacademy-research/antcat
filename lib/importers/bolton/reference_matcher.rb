# coding: UTF-8
class Importers::Bolton::ReferenceMatcher < ::ReferenceMatcher

  def match target
    matches = super
    max_similarity = matches.map {|e| e[:similarity]}.max || 0
    matches = matches.select {|match| match[:similarity] == max_similarity}
    {:similarity => max_similarity, :matches => matches}
  end

  def possible_match? _, _
    true
  end

end

