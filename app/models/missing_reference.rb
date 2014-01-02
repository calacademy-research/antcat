# coding: UTF-8
class MissingReference < Reference

  def key
    MissingReferenceKey.new citation
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
