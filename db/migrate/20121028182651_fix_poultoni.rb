class FixPoultoni < ActiveRecord::Migration
  def up
    Importers::Bolton::Catalog::Species::Importer.set_synonym  'Prionopelta poultoni', 'Prionopelta majuscula'
  end
end
