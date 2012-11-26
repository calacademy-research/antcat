class FixPicena < ActiveRecord::Migration
  def up
    picena = Taxon.find_by_name 'Aphaenogaster picena'
    picena.update_attribute :status, 'valid'
  end
end
