# coding: UTF-8
class TaxonHistoryItem < ActiveRecord::Base
  belongs_to :taxon

  attr_accessible :taxon_id, :taxt, :position, :taxon
  acts_as_list scope: :taxon
  validates_presence_of :taxt
  has_paper_trail

  # TOOD: Rails 4 upgrade, remove when tests pass
  # def title
  #   # for PaperTrailManager's RSS output
  #   taxt
  # end

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
