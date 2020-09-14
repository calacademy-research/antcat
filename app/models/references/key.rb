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

    def authors_for_key
      names = author_names.map(&:last_name)

      case names.size
      when 0 then '[no authors]' # TODO: This can still happen in the reference form.
      when 1 then names.first.to_s
      when 2 then "#{names.first} & #{names.second}"
      else        "#{names.first} <i>et al.</i>"
      end.html_safe
    end

    private

      delegate :year, :suffixed_year, :author_names, to: :reference, private: true
  end
end
