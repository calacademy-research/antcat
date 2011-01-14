class Antweb::Exporter
  def self.export show_progress = false
    Taxon.import do |save_proc|
      Antweb::Taxonomy.all.each do |taxonomy|
        save_proc.call :genus => taxonomy.name, :tribe => taxonomy.tribe, :subfamily => taxonomy.subfamily,
                       :available => taxonomy.available, :is_valid => taxonomy.is_valid
      end
    end
  end
end
