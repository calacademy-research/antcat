# coding: UTF-8
class MissingReference < Reference

  def key
    MissingReferenceKey.new citation
  end

  def self.replace_all show_progress = false
    unfound_citations = []
    records_to_destroy = []
    replacements = []
    Progress.new_init show_progress: show_progress, total_count: count
    order(:citation).all.each do |reference|
      replacement = reference.find_replacement
      if replacement
        replacements << {replace: reference, with: replacement}
        records_to_destroy << reference.id
      else
        unfound_citations << reference.citation
        Progress.puts reference.citation
        next
      end
    end

    replace_with_batch replacements

    for id in records_to_destroy
      find(id).destroy
    end

    unfound_citations
  end

  def find_replacement
    results = Reference.where key_cache: citation
    results.first
  end

  def self.import reason, data
    year = data[:year] || data[:in].try(:[], :year)
    reference_key = data[:matched_text].dup

    first_colon_index = reference_key.index ':'
    reference_key = reference_key[0, first_colon_index] if first_colon_index

    missing_reference = find_by_citation reference_key
    return missing_reference if missing_reference

    create! title: '(missing)', reason_missing: reason, citation: reference_key, citation_year: year
  end

end
