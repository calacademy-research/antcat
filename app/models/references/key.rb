# frozen_string_literal: true

module References
  class Key
    attr_private_initialize :reference

    # Looks like: "Forel, Emery & Mayr, 1878b" (and without the "b" if `suffixed_year` is blank).
    def key_with_suffixed_year
      authors_for_key << ', ' << suffixed_year
    end

    # Looks like: "Forel, Emery & Mayr, 1878".
    def key_with_year
      authors_for_key << ', ' << year.to_s
    end

    # Marked HTML-safe (for `<i>et al.</i>`): `<`, `>` and `&` in a name are escaped. `AuthorName` refuses them
    # in new names, but older names were not checked. Quotes stay as they are (the key is also plain text).
    def authors_for_key
      names = author_names.map { |author_name| escape_markup(author_name.last_name) }

      case names.size
      when 0 then '[no authors]' # TODO: This can still happen in the reference form.
      when 1 then names.first.to_s
      when 2 then "#{names.first} & #{names.second}"
      else        "#{names.first} <i>et al.</i>"
      end.html_safe
    end

    private

      def escape_markup text
        text.to_s.gsub(/[&<>]/, '&' => '&amp;', '<' => '&lt;', '>' => '&gt;')
      end

      delegate :year, :suffixed_year, :author_names, to: :reference, private: true
  end
end
