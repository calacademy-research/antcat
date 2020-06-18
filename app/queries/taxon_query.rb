# frozen_string_literal: true

class TaxonQuery
  def initialize relation = Taxon.all
    @relation = relation
  end

  def order_by_epithet
    relation.joins(:name).order('names.epithet')
  end

  def pass_through_names
    relation.where(status: Status::PASS_THROUGH_NAMES)
  end

  def excluding_pass_through_names
    relation.where.not(status: Status::PASS_THROUGH_NAMES)
  end

  def with_common_includes
    relation.
      includes(:name, protonym: [:name, { authorship: { reference: :author_names } }]).
      references(:reference_author_names)
  end

  def with_common_includes_and_current_taxon_includes
    with_common_includes.
      includes(current_taxon: [:name, protonym: [:name, { authorship: { reference: :author_names } }]])
  end

  private

    attr_reader :relation
end
