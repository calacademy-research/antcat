# frozen_string_literal: true

module References
  class Key
    attr_private_initialize :reference

    # Two forms of the key:
    # * HTML (`key_with_suffixed_year`, `key_with_year`, `authors_for_key`): marked HTML-safe, with `<i>et al.</i>`;
    #   `<`, `>` and `&` in a name are escaped (`AuthorName` refuses them in new names, older names were not
    #   checked). For views, HTML fields and the cached key. Quotes stay as they are (no attribute is built here).
    # * Plain text (`plain_text_*`): the names as they are and "et al." without markup. For page titles, meta tags,
    #   search indexing and JSON fields shown as text.

    # Looks like: "Forel, Emery & Mayr, 1878b" (and without the "b" if `suffixed_year` is blank).
    def key_with_suffixed_year
      authors_for_key << ', ' << suffixed_year
    end

    # Looks like: "Forel, Emery & Mayr, 1878".
    def key_with_year
      authors_for_key << ', ' << year.to_s
    end

    def authors_for_key
      join_names(author_names.map { |author_name| escape_markup(author_name.last_name) }, et_al: ' <i>et al.</i>').html_safe
    end

    def plain_text_key_with_suffixed_year
      "#{plain_text_authors_for_key}, #{suffixed_year}"
    end

    def plain_text_key_with_year
      "#{plain_text_authors_for_key}, #{year}"
    end

    def plain_text_authors_for_key
      join_names author_names.map(&:last_name), et_al: ' et al.'
    end

    private

      delegate :year, :suffixed_year, :author_names, to: :reference, private: true

      # A new, unfrozen string (`key_with_year` appends to it).
      def join_names names, et_al:
        case names.size
        when 0 then +'[no authors]' # TODO: This can still happen in the reference form.
        when 1 then names.first.to_s.dup
        when 2 then "#{names.first} & #{names.second}"
        else        "#{names.first}#{et_al}"
        end
      end

      def escape_markup text
        text.to_s.gsub(/[&<>]/, '&' => '&amp;', '<' => '&lt;', '>' => '&gt;')
      end
  end
end
