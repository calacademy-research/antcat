# coding: UTF-8
class Vlad

  def self.idate show_progress = false
    Progress.new_init show_progress: show_progress, log_file_name: 'vlad', append_to_log_file: !Rails.env.test?
    results = {}
    results.merge! record_counts
    display results
  end

  def self.display results
    results[:record_counts].each do |model_class, count|
      Progress.log "#{count.to_s.rjust(7)} #{model_class}"
    end
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
