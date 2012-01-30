# coding: UTF-8
class Vlad

  def self.idate show_progress = false
    Progress.new_init show_progress: true

    results = {}
    results.merge! record_counts
    results.merge! genera_with_tribes_but_not_subfamilies
    results.merge! taxa_with_mismatched_synonym_and_status

    display results
    results
  end

  def self.display results
    results_section = results[:record_counts]
    results_section.each do |model_class, count|
      Progress.puts "#{count.to_s.rjust(7)} #{model_class}"
    end

    results_section = results[:genera_with_tribes_but_not_subfamilies]
    Progress.print "Genera with tribes but not subfamilies:"
    if results_section.blank?
      Progress.puts " none"
    else
      Progress.puts
      results_section.map do |genus|
        "#{genus.name} (tribe #{genus.tribe.name})"
      end.sort.each do |name|
        Progress.puts name
      end
    end

    results_section = results[:taxa_with_mismatched_synonym_and_status]
    Progress.print "Taxa with mismatched synonym status and synonym_of_id:"
    if results_section.blank?
      Progress.puts " none"
    else
      Progress.puts
      results_section.map do |taxon|
        "#{taxon.name} #{taxon.status} #{taxon.synonym_of_id}"
      end.sort.each do |line|
        Progress.puts line
      end
    end

  end

  def self.taxa_with_mismatched_synonym_and_status
    {taxa_with_mismatched_synonym_and_status: Taxon.where("(status = 'synonym') = (synonym_of_id IS NULL)")}
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
