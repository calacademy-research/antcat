class Antweb::Exporter
  def self.export show_progress = false
    Progress.init show_progress, Antweb::Taxonomy.count
    Taxon.import do |proc|
      Antweb::Taxonomy.all.each do |taxonomy|
        proc.call :genus => taxonomy.name, :tribe => taxonomy.tribe, :subfamily => taxonomy.subfamily,
                  :available => taxonomy.available, :is_valid => taxonomy.is_valid
        Progress.tally_and_show_progress 50
      end
    end
    Progress.show_results
  end
end
