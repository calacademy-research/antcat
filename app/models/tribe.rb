# coding: UTF-8
class Tribe < Taxon
  belongs_to :subfamily
  has_many :genera, class_name: 'Genus', order: :name

  def children
    genera
  end

  def full_name
    "#{subfamily.name} #{name}"
  end

  def full_label
    full_name
  end

  def statistics
  end

  def siblings
    subfamily.tribes
  end

end
