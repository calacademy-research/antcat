# frozen_string_literal: true

class HistoryItemQuery
  SEARCH_TYPES = [
    LIKE = 'LIKE',
    REGEXP = 'REGEXP'
  ]

  def initialize relation = HistoryItem.all
    @relation = relation
  end

  def search search_query, search_type
    search_type = search_type.presence || LIKE

    case search_type
    when LIKE
      return visible_text_search.matching(relation, search_query) unless Current.signed_in
      relation.where("taxt LIKE :q", q: "%#{search_query}%")
    when REGEXP
      relation.where("taxt REGEXP :q", q: search_query)
    else
      raise "unknown search_type #{search_type}"
    end
  end

  def exclude_search search_query, search_type
    search_type = search_type.presence || LIKE

    case search_type
    when LIKE
      return visible_text_search.not_matching(relation, search_query) unless Current.signed_in
      relation.where.not("taxt LIKE :q", q: "%#{search_query}%")
    when REGEXP
      relation.where.not("taxt REGEXP :q", q: search_query)
    else
      raise "unknown search_type #{search_type}"
    end
  end

  private

    attr_reader :relation

    # Visitors (not signed in) search the text without hidden notes; see `VisibleTaxtLikeSearch`.
    # REGEXP searches need a signed-in user (`ensure_regexp_search_allowed`).
    def visible_text_search
      VisibleTaxtLikeSearch.new(HistoryItem, ['history_items.taxt'])
    end
end
