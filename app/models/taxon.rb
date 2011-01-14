class Taxon < ActiveRecord::Base
  set_table_name :taxa

  belongs_to :parent, :class_name => 'Taxon'
  has_many :children, :class_name => 'Taxon', :foreign_key => :parent_id

  def self.import
    transaction do
      destroy_all
      yield lambda {|hash|
        subfamily = find_or_create_by_name :name => hash[:subfamily], :rank => 'subfamily'
        genus = create! :name => hash[:genus], :rank => 'genus', :available => hash[:available], :is_valid => hash[:is_valid]
        if hash[:tribe].present?
          genus.update_attributes :parent => find_or_create_by_name(:name => hash[:tribe], :rank => 'tribe', :parent => subfamily)
        else
          genus.update_attributes :parent => subfamily
        end
      }
    end
  end

  def available?
    available
  end

  def is_valid?
    is_valid
  end
end
