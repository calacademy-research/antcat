class FixInvicta < ActiveRecord::Migration
  def up
    Importers::Bolton::Catalog::Species::Importer.set_synonym  'Solenopsis wagneri', 'Solenopsis invicta'
  end
end
