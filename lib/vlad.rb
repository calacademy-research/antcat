# coding: UTF-8
class Vlad

  def self.idate show_progress = false
    Progress.new_init show_progress: show_progress,
                      log_file_directory: 'data/vlad',
                      log_file_name: 'vlad',
                      append_to_log_file: !Rails.env.test?
    results = {}
    results.merge! record_counts
    results.merge! genera_with_tribes_but_not_subfamilies
    display results
    results
  end

  def self.display results
    results[:record_counts].each do |model_class, count|
      Progress.log "#{count.to_s.rjust(7)} #{model_class}"
    end

    results = results[:genera_with_tribes_but_not_subfamilies]
    unless results.blank?
      Progress.puts "Genera with tribes but not subfamilies"
      results.map do |genus|
        "#{genus.name} (tribe #{genus.tribe.name})"
      end.sort.each do |name|
        Progress.puts name
      end
    end
  end

  def self.genera_with_tribes_but_not_subfamilies
    {genera_with_tribes_but_not_subfamilies: Genus.where("tribe_id IS NOT NULL AND subfamily_id IS NULL")}
  end

  def self.record_counts
    {:record_counts => [
      AuthorName,
      Author,
      Bolton::Match,
      Bolton::Reference,
      Citation,
      ForwardReference,
      Journal,
      Place,
      Protonym,
      Publisher,
      ReferenceAuthorName,
      ReferenceDocument,
      Reference,
      Taxon,
      TaxonomicHistoryItem,
      User,
    ].inject({}) do |counts, table|
      counts[table] = table.count
      counts
    end}
  end

end
