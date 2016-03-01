class MissingReference < Reference

  def self.find_replacements show_progress
    Progress.init show_progress, MissingReference.count
    unfound_citations = []
    records_to_destroy = []
    replacements = []
    order(:citation).all.each do |reference|
      replacement = reference.find_replacement
      if replacement
        replacements << { replace: reference.id, with: replacement.id }
        records_to_destroy << reference.id
      else
        unfound_citations << reference.citation
      end
      Progress.tally_and_show_progress 50
    end
    Progress.show_results
    return replacements, unfound_citations, records_to_destroy
  end

  def self.replace_citation citation, replacement
    records_to_replace = MissingReference.where(citation: citation)
    replacements = records_to_replace.all.inject [] do |replacements, reference|
      replacements << { replace: reference.id, with: replacement.id }
    end
    replace_with_batch replacements
    destroy_found_missing_references records_to_replace
  end

  def replace_citation_with replacement
    self.class.replace_citation citation, replacement
  end

  def self.replace_all show_progress = false
    replacements, unfound_citations, records_to_destroy = find_replacements show_progress
    replace_with_batch replacements, show_progress
    destroy_found_missing_references records_to_destroy
    unfound_citations
  end

  def self.destroy_found_missing_references records_to_destroy
    Progress.puts "#{records_to_destroy.count} MissingReferences to delete"
    records_to_destroy.each do |id|
      find(id.id).destroy
    end
  end

  def find_replacement
    search_term = citation.gsub /,/, ''
    Reference.where(key_cache_no_commas: search_term).first
  end

end
