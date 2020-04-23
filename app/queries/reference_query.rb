# frozen_string_literal: true

class ReferenceQuery
  def initialize relation = Reference.all
    @relation = relation
  end

  def latest_additions
    relation.order(created_at: :desc)
  end

  def latest_changes
    relation.order(updated_at: :desc)
  end

  private

    attr_reader :relation
end
