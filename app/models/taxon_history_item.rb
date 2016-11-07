class TaxonHistoryItem < ActiveRecord::Base
  include UndoTracker
  include Feed::Trackable

  attr_accessible :taxon_id, :taxt, :position, :taxon

  belongs_to :taxon

  validates_presence_of :taxt

  acts_as_list scope: :taxon
  has_paper_trail meta: { change_id: :get_current_change_id }
  tracked on: :all, parameters: ->(item) do { taxon_id: item.taxon_id } end

  def update_taxt_from_editable editable_taxt
    update_attributes taxt: Taxt.from_editable(editable_taxt)
  rescue Taxt::ReferenceNotFound => e
    errors.add :base, "The reference '#{e}' could not be found. Was the ID changed?"
  end

  def self.create_taxt_from_editable taxon, editable_taxt
    TaxonHistoryItem.create taxon: taxon, taxt: Taxt.from_editable(editable_taxt)
  rescue Taxt::ReferenceNotFound => e
    errors.add :base, "The reference '#{e}' could not be found. Was the ID changed?"
  end
end
