# coding: UTF-8
class MissingReference < Reference

  def self.import reason, data
    year = data[:year] || data[:in].try(:[], :year)
    reference_key = data[:reference_text].dup

    first_colon_index = reference_key.index ':'
    reference_key = reference_key[0, first_colon_index] if first_colon_index

    create! title: '(missing)', reason_missing: reason, citation: reference_key, citation_year: year
  end

  def key
    MissingReferenceKey.new citation
  end

end
