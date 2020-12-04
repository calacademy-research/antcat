# frozen_string_literal: true

class HistoryItemQuery
  def initialize relation = HistoryItem.all
    @relation = relation
  end

  def search search_query, search_type
    search_type = search_type.presence || 'LIKE'

    case search_type
    when 'LIKE'
      relation.where("taxt LIKE :q", q: "%#{search_query}%")
    when 'REGEXP'
      relation.where("taxt REGEXP :q", q: search_query)
    else
      raise "unknown search_type #{search_type}"
    end
  end

  def exclude_search search_query, search_type
    search_type = search_type.presence || 'LIKE'

    case search_type
    when 'LIKE'
      relation.where.not("taxt LIKE :q", q: "%#{search_query}%")
    when 'REGEXP'
      relation.where.not("taxt REGEXP :q", q: search_query)
    else
      raise "unknown search_type #{search_type}"
    end
  end

  private

    attr_reader :relation
end
