# coding: UTF-8
class TaxonHistoryItem < ActiveRecord::Base
  belongs_to :taxon
  acts_as_list scope: :taxon
  validates_presence_of :taxt

  has_paper_trail

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
