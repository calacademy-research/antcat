# coding: UTF-8
class GenusGroupTaxon < Taxon
  belongs_to :subfamily
  belongs_to :tribe

  def children
    species
  end

  def label
    "<i>#{name}</i>"
  end

  def inspect
    string = super
    string << ' (' if subfamily || tribe
    if subfamily
      string << " #{subfamily.name} #{subfamily.id}"
      string << " #{subfamily.status}" if subfamily.invalid?
    end
    if tribe
      string << " #{tribe.name} #{tribe.id}"
      string << " #{tribe.status}" if tribe.invalid?
    end
    string << ')' if subfamily || tribe
    string
  end

end
