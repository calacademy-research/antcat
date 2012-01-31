# coding: UTF-8
class Vlad

  def self.idate show_progress = false
    Progress.new_init show_progress: show_progress

    results = {}
    results.merge! record_counts
    results.merge! genera_with_tribes_but_not_subfamilies
    results.merge! taxa_with_mismatched_synonym_and_status
    results.merge! taxa_with_mismatched_homonym_and_status
    results.merge! duplicates

    display results
    results
  end

  def self.display results
    results_section = results[:record_counts]
    results_section.each do |model_class, count|
      Progress.puts "#{count.to_s.rjust(7)} #{model_class}"
    end
    Progress.puts

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
    Progress.puts

    results_section = results[:taxa_with_mismatched_synonym_and_status]
    Progress.print "Taxa with mismatched synonym status and synonym_of_id:"
    if results_section.blank?
      Progress.puts " none"
    else
      Progress.puts
      results_section.map do |result|
        "#{result.name} #{result.status} #{result.synonym_of_id}"
      end.sort.each do |line|
        Progress.puts line
      end
    end
    Progress.puts

    results_section = results[:taxa_with_mismatched_homonym_and_status]
    Progress.print "Taxa with mismatched homonym status and homonym_replaced_by_id:"
    if results_section.blank?
      Progress.puts " none"
    else
      Progress.puts
      results_section.map do |result|
        "#{result.name} #{result.status} #{result.homonym_replaced_by_id}"
      end.sort.each do |line|
        Progress.puts line
      end
    end
    Progress.puts

    results_section = results[:duplicates]
    Progress.print "Duplicates:"
    if results_section.blank?
      Progress.puts " none"
    else
      Progress.puts
      results_section.map do |result|
        "#{result[:name]} #{result[:count]}"
      end.sort.each do |line|
        Progress.puts line
      end
    end
    Progress.puts

  end

  def self.duplicates
    {duplicates: Taxon.select('name, COUNT(name) AS count').group(:name, :genus_id).having('COUNT(name) > 1')}
  end

  def self.taxa_with_mismatched_synonym_and_status
    {taxa_with_mismatched_synonym_and_status: Taxon.where("(status = 'synonym') = (synonym_of_id IS NULL)")}
  end

  def self.taxa_with_mismatched_homonym_and_status
    {taxa_with_mismatched_synonym_and_status: Taxon.where("(status = 'homonym') = (homonym_replaced_by_id IS NULL)")}
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
