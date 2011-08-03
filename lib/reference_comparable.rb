module ReferenceComparable
  def <=> rhs
    return 0.00 unless type == rhs.type
    return 0.00 unless normalize_author(author) == normalize_author(rhs.author)

    result = match_title(rhs) || match_article(rhs) || match_book(rhs)
    year_matches = year_matches? rhs
    pagination_matches = pagination_matches? rhs

    case
    when !result && !year_matches then 0.00
    when !result && year_matches then 0.10
    when result && !year_matches then result - 0.50
    when result && !pagination_matches then result - 0.01
    else result
    end
  end

  private
  def year_matches? rhs
    return unless rhs.year && year
    (rhs.year.to_i - year.to_i).abs <= 1
  end

  def pagination_matches? rhs
    rhs.pagination == pagination
  end

  def match_title rhs
    other_title = rhs.title.dup
    title = self.title.dup
    return 1.00 if normalize_title!(other_title) == normalize_title!(title)

    remove_bracketed_phrases!(other_title)
    remove_bracketed_phrases!(title)
    return unless other_title.present? and title.present?
    return 0.95 if other_title == title

    return 0.94 if replace_roman_numerals!(other_title) == replace_roman_numerals!(title)
    return 1.00 if remove_punctuation!(other_title) == remove_punctuation!(title)
  end

  def match_article rhs
    return unless rhs.type == 'ArticleReference' && type == 'ArticleReference' &&
      rhs.series_volume_issue.present? && series_volume_issue.present? &&
      rhs.pagination.present? && pagination.present? &&
      rhs.pagination == pagination

    return 0.90 if normalize_series_volume_issue(rhs.series_volume_issue) ==
                 normalize_series_volume_issue(series_volume_issue)
  end

  def match_book rhs
    return unless rhs.type == 'BookReference' && type == 'BookReference' &&
      rhs.pagination.present? && pagination.present?
    return 0.80 if rhs.pagination == pagination
  end

  def normalize_series_volume_issue string
    string = string.dup
    remove_year_in_parentheses! string
    remove_No! string
    replace_punctuation_with_space! string
    string
  end

  def replace_punctuation_with_space! string
    string.gsub! /[[:punct:]]/, ' '
    string.squish!
    string
  end

  def remove_space_before_or_after_parenthesis! string
    string.gsub! /\s?([\(\)])\s?/, '\1'
    string
  end

  def remove_year_in_parentheses! string
    string.gsub! /\(\d{4}\)$/, ''
    string
  end

  def remove_No! string
    string.gsub! /\(No. (\d+)\)$/, '(\1)'
    string
  end

  def normalize_title! string
    remove_parenthesized_taxon_names! string
    string.downcase!
    convert_accents_to_ascii! string
    string
  end

  def remove_punctuation! string
    string.gsub! /[^\w\s]/, ''
    string
  end

  def convert_accents_to_ascii! string
    string.replace convert_accents_to_ascii string
  end

  def convert_accents_to_ascii string
    string.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,"")
  end

  def normalize_author string
    convert_accents_to_ascii(string).downcase
  end

  def remove_parenthesized_taxon_names! string
    match = string.match(/ \(.+?\)/)
    return string unless match
    possible_taxon_names = match.to_s.strip.gsub(/[(),:]/, '').split(/[ ]/)
    any_taxon_names = possible_taxon_names.any? do |word|
      ['Formicidae', 'Hymenoptera'].include? word
    end
    string[match.begin(0)..(match.end(0) - 1)] = '' if any_taxon_names
    string
  end

  def remove_bracketed_phrases! string
    string.gsub!(/\s?\[.*?\]\s?/, ' ')
    string.strip!
    string
  end

  def replace_roman_numerals! string
    [['i', 1], ['ii', 2], ['iii', 3], ['iv', 4], ['v', 5], ['vi', 6], ['vii', 7], ['viii', 8], ['ix', 9], ['x', 10]
    ].each do |roman, arabic|
      string.gsub! /\b#{roman}\b/, arabic.to_s
    end
    string
  end

end
