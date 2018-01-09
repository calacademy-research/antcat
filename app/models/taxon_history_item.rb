class TaxonHistoryItem < ApplicationRecord
  include Trackable
  include PrimitiveSearch
  include RevisionsCanBeCompared

  belongs_to :taxon

  validates_presence_of :taxt

  acts_as_list scope: :taxon
  has_paper_trail meta: { change_id: proc { UndoTracker.get_current_change_id } }
  has_primitive_search where: ->(search_type) { "taxt #{search_type} :q" }
  strip_attributes only: [:taxt], replace_newlines: true
  tracked on: :mixin_create_activity_only, parameters: proc { { taxon_id: taxon_id } }

  def self.create_taxt_from_editable taxon, editable_taxt
    TaxonHistoryItem.create taxon: taxon, taxt: TaxtConverter[editable_taxt].from_editor_format
  rescue TaxtConverter::ReferenceNotFound => e
    errors.add :base, "The reference '#{e}' could not be found. Was the ID changed?"
  end

  # TODO create new concern or proper class.
  # Error handling, updating, etc, should be the same for taxts in other classes too.
  def update_taxt_from_editable editable_taxt
    update taxt: TaxtConverter[editable_taxt].from_editor_format
  rescue TaxtConverter::ReferenceNotFound => e
    errors.add :base, "The reference '#{e}' could not be found. Was the ID changed?"
  end
end
