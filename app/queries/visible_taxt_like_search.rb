# frozen_string_literal: true

# `LIKE '%q%'` searches on taxt columns that match only the text visitors can see, that is the taxt
# without its `{hiddennote ...}` parts (see `Taxt.remove_hidden_notes`). Used for visitors (not signed in),
# so the content of hidden notes cannot be found by searching.
#
# Rows without a hidden note are matched in SQL exactly as before. The few rows that contain a hidden note
# and match the raw text are checked again in Ruby against the visible text; the ids that still match are
# passed back to SQL, so the result is a normal relation (pagination and counts work as before).
class VisibleTaxtLikeSearch
  HIDDENNOTE_LIKE = "%#{Taxt::HIDDENNOTE_OPENING}%"
  NO_ID = -1
  REGEXP_TIMEOUT = 0.1 # seconds; a row whose check times out is treated as not matching.

  # `columns` are SQL column names qualified with their table, e.g. "history_items.taxt".
  def initialize model, columns
    @model = model
    @columns = columns
  end

  # Rows where the visible text of any of the columns is `LIKE '%search_query%'`.
  def matching relation, search_query
    relation.where(*condition(search_query))
  end

  # Rows where the visible text of none of the columns is `LIKE '%search_query%'`.
  def not_matching relation, search_query
    relation.where.not(*condition(search_query))
  end

  private

    attr_reader :model, :columns

    def condition search_query
      pattern = "%#{search_query}%"
      ids = ids_of_rows_with_notes_matching_visible_text(pattern).presence || [NO_ID]

      sql = <<~SQL.squish
        (#{any_column('LIKE :pattern')})
          AND (NOT (#{any_column('LIKE :note')}) OR #{model.quoted_table_name}.id IN (:ids))
      SQL
      [sql, { pattern: pattern, note: HIDDENNOTE_LIKE, ids: ids }]
    end

    def any_column sql_operation
      columns.map { |column| "COALESCE(#{column}, '') #{sql_operation}" }.join(' OR ')
    end

    def ids_of_rows_with_notes_matching_visible_text pattern
      regex = like_regex(pattern)

      model.unscoped.
        where(any_column('LIKE :pattern'), pattern: pattern).
        where(any_column('LIKE :note'), note: HIDDENNOTE_LIKE).
        pluck(Arel.sql("#{model.quoted_table_name}.id"), *columns.map { Arel.sql(it) }).
        select { |(_id, *values)| values.any? { |value| visible_text_matches?(value, regex) } }.
        map(&:first)
    end

    def visible_text_matches? value, regex
      return false if value.nil?
      regex.match?(fold(Taxt.remove_hidden_notes(value)))
    rescue Regexp::TimeoutError
      false
    end

    # MySQL `LIKE` in Ruby: `%` is any text, `_` any one character, `\` escapes the next character.
    # Case and accents are ignored, as in the database's case- and accent-insensitive collations.
    def like_regex pattern
      source = +''
      chars = pattern.chars
      index = 0

      while index < chars.size
        char = chars[index]
        if char == '\\' && index + 1 < chars.size
          index += 1
          source << Regexp.escape(fold(chars[index]))
        elsif char == '%'
          source << '.*' unless source.end_with?('.*')
        elsif char == '_'
          source << '.'
        else
          source << Regexp.escape(fold(char))
        end
        index += 1
      end

      Regexp.new("\\A#{source}\\z", Regexp::MULTILINE, timeout: REGEXP_TIMEOUT)
    end

    def fold text
      text.unicode_normalize(:nfd).gsub(/\p{Mn}/, '').downcase(:fold)
    end
end
