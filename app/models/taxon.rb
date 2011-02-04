class Taxon < ActiveRecord::Base
  set_table_name :taxa

  def unavailable?
    status == 'unavailable'
  end

  def invalid?
    status != 'valid'
  end

  def children
    raise NotImplementedError
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
