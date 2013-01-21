# coding: UTF-8
class MissingReference < Reference

  def self.import reason, data
    year = data[:year] || data[:in].try(:[], :year)
    reference_key = data[:matched_text].dup

    first_colon_index = reference_key.index ':'
    reference_key = reference_key[0, first_colon_index] if first_colon_index

    missing_reference = find_by_citation reference_key
    if missing_reference
      Progress.puts "Found an existing missing_reference"
      return missing_reference
    end

    create! title: '(missing)', reason_missing: reason, citation: reference_key, citation_year: year
  end

  def key
    MissingReferenceKey.new citation
  end

end
