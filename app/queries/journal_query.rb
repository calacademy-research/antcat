# frozen_string_literal: true

class JournalQuery
  REFERENCE_COUNT_ORDER = "reference_count"

  delegate :includes_reference_count, :with_order, to: :relation

  def initialize relation = Journal.all
    @relation = relation.extending(Scopes)
  end

  private

    attr_reader :relation

    module Scopes
      def includes_reference_count
        left_joins(:references).group(:id).select("journals.*, COUNT(references.id) AS reference_count")
      end

      def with_order order_by
        if order_by == REFERENCE_COUNT_ORDER
          order("reference_count DESC")
        else
          order(:name)
        end
      end
    end
end
