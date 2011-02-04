class Taxon < ActiveRecord::Base
  set_table_name :taxa

  belongs_to :parent, :class_name => 'Taxon'
  has_many :children, :class_name => 'Taxon', :foreign_key => :parent_id, :order => :name
  def unavailable?
    status == 'unavailable'
  end

  def invalid?
    status != 'valid'
  end

  def genera
    children.inject([]) do |genera, child|
      if child.kind_of? Genus
        genera << child
      else
        genera.concat child.genera
      end
      genera
    end.sort_by(&:name)
  end

  def self.import
    transaction do
      delete_all
      yield lambda {|hash|
        subfamily = hash[:subfamily].present? ? Subfamily.find_or_create_by_name(:name => hash[:subfamily]) : nil
        genus = Genus.create! :name => hash[:genus], :available => hash[:available], :is_valid => hash[:is_valid]
        if hash[:tribe].present?
          genus.update_attributes :parent => Tribe.find_or_create_by_name(:name => hash[:tribe], :parent => subfamily)
        else
          genus.update_attributes :parent => subfamily
        end
      }
    end
  end

end
