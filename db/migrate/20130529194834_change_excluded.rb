class ChangeExcluded < ActiveRecord::Migration
  def up
    Taxon.update_all 'status = "excluded from Formicidae"', 'status = "excluded"'
  end

  def down
  end
end
