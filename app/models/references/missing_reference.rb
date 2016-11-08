# TODO remove this whole thing? Possibly not actively used by editors,
# and since `key_cache` isn't updated, this feature doesn't work as intended,
# and the intended usage was pretty dangerous to begin with.

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
    replacements = records_to_replace.map do |reference|
      { replace: reference.id, with: replacement.id }
    end
    replace_with_batch replacements
    destroy_found_missing_references records_to_replace
  end

  def replace_citation_with replacement
    MissingReference.replace_citation citation, replacement
    create_replace_missing_reference_activity replacement
  end

  def self.replace_all show_progress = false
    replacements, unfound_citations, records_to_destroy = find_replacements show_progress
    replace_with_batch replacements, show_progress
    destroy_found_missing_references records_to_destroy
    unfound_citations
  end

  def self.destroy_found_missing_references records_to_destroy
    Progress.puts "#{records_to_destroy.count} MissingReferences to delete"
    records_to_destroy.each { |id| find(id.id).destroy }
  end

  # TODO remove? `references.key_cache_no_commas` was removed in
  # `20140116210057_rename_nester.rb`.
  def find_replacement
    search_term = citation.gsub /,/, ''
    Reference.where(key_cache_no_commas: search_term).first
  end

  private
    def create_replace_missing_reference_activity replacement
      Feed::Activity.create_activity :replace_missing_reference,
        citation: citation,
        reason_missing: reason_missing,
        replacement_id: replacement.id
    end
end
