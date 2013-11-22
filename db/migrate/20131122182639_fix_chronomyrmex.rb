class FixChronomyrmex < ActiveRecord::Migration
  def up
    chronomyrmex = Taxon.find_by_name 'Chronomyrmex'
    raise "Can't find Chronomyrmex" unless chronomyrmex

    leptomyrmecini = Taxon.find_by_name 'Leptomyrmecini'
    raise "Can't find Leptomyrmecini" unless leptomyrmecini

    chronomyrmex.tribe = leptomyrmecini
    chronomyrmex.save!
  end

  def down
  end
end
