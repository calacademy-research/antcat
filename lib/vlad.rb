# coding: UTF-8
class Vlad

  def self.idate show_progress = false
    Progress.new_init show_progress: show_progress
    Progress.puts

    #Statistic.descendants.each &:display
    Problem.descendants.each &:display
  end

  class Report
    def self.display_results_section results, options = {}
      return unless results.present?
      options = options.reverse_merge sort: true
      display_section_header results.count
      lines = results.map {|item| yield item}
      lines.sort! if options[:sort]
      lines.reverse! if options[:reverse_order]
      lines.each {|line| Progress.puts '  ' + line}
      display_section_header results.count if results.count > 100

      Progress.puts
    end

    def self.display_section_header count
      Progress.puts "#{self.name.demodulize.titleize.capitalize}: #{count}"
    end

  end

  class Problem < Report
  end

  class Statistic < Report
  end

  class TaxonCounts < Statistic
    def self.display
      display_results_section query, sort: false do |count|
        "#{count.first.rjust(11)} #{count.second}"
      end
    end
    def self.query
      Taxon.select('type, COUNT(*) AS count').group(:type).map do |result|
        [result['type'], result['count'].to_i]
      end
    end
  end

  class StatusCounts < Statistic
    def self.display
      display_results_section query, sort: false do |count|
        "#{count.first.rjust(19)} #{count.second}"
      end
    end
    def self.query
      Taxon.select('status, COUNT(*) AS count').group(:status).order('count DESC').map do |result|
        [result['status'], result['count'].to_i]
      end
    end
  end

  class RecordCounts < Statistic
    def self.display
      display_results_section query, sort: false do |result|
        "#{result[:count].to_s.rjust(7)} #{result[:table]}"
      end
    end
    def self.query
      [ AuthorName,
        Author,
        Bolton::Match,
        Bolton::Reference,
        Citation,
        Journal,
        Place,
        Protonym,
        Publisher,
        ReferenceAuthorName,
        ReferenceDocument,
        Reference,
        SpeciesGroupForwardRef,
        Taxon,
        TaxonomicHistoryItem,
        User,
      ].map do |table|
        {table: table.to_s, count: table.count}
      end
    end
  end

  class ReferenceDocumentCounts < Statistic
    def self.display
      return
      Progress.puts "Reference documents"
      results = query
      Progress.puts "  #{results[:references_count].to_s.rjust(7)} references"
      Progress.puts "  #{results[:reference_documents_count].to_s.rjust(7)} reference documents"
      Progress.puts "  #{results[:references_with_documents_count].to_s.rjust(7)} references with documents"
      for result in results[:locations]
        Progress.puts "  #{result.second.to_s.rjust(7)} #{result.first}"
      end
      Progress.puts
    end
    def self.query
     value = {
      references_count: Reference.non_missing.count,
      reference_documents_count: ReferenceDocument.count,
      references_with_documents_count: Reference.find_by_sql('select count(distinct `references`.id) as count from `references` join reference_documents on `references`.id = reference_documents.reference_id').first[:count],
    }
    locations = {antcat: 0, antbase: 0, ip_128_146_250_117: 0, other: 0}
    for reference in Reference.non_missing do
      next unless reference.document
      case reference.document.url
      when /antcat/ then locations[:antcat] += 1
      when /antbase/ then locations[:antbase] += 1
      when /128.146.250.117/ then locations[:ip_128_146_250_117] += 1
      else locations[:other] += 1
      end
    end
    value[:locations] = locations
    value
    end
  end

  ##############################################################################

  class GeneraWithTribesButNotSubfamilies < Problem
    def self.display
      display_results_section query do |genus|
        "#{genus.name} (tribe #{genus.tribe.name})"
      end
    end
    def self.query
      Genus.where "tribe_id IS NOT NULL AND subfamily_id IS NULL"
    end
  end

  class TaxaWithMismatchedHomonymAndStatus < Problem
    def self.display
      display_results_section query do |taxon|
        "#{taxon.name} (#{taxon.status}) #{taxon.homonym_replaced_by_id}"
      end
    end
    def self.query
      Taxon.where "(status = 'homonym') = (homonym_replaced_by_id IS NULL)"
    end
  end

  class SubspeciesWithoutSpecies < Problem
    def self.display
      display_results_section query, reverse_order: true do |taxon|
        "#{taxon.name} (#{taxon.status})"
      end
    end
    def self.query
      Subspecies.where "species_id IS NULL"
    end
  end

  class TaxaWithMismatchedSynonymAndStatus < Problem
    def self.display
      display_results_section query, reverse_order: true do |taxon|
        "#{taxon.name} (#{taxon.status}) #{taxon.synonym_of_id}"
      end
    end
    def self.query
      Taxon.where "(status = 'synonym') = (synonym_of_id IS NULL)"
    end
  end

  class DuplicateValids < Problem
    def self.display
      display_results_section query do |duplicate|
        "#{duplicate[:name]} #{duplicate[:count]}"
      end
    end
    def self.query
     Taxon.select('names.name AS name, COUNT(names.name) AS count').
           with_names.
           group('names.name', :genus_id).
           where(status: 'valid').
           having('COUNT(names.name) > 1').
           all.
           map {|row| {name: row['name'], count: row['count']}}
    end
  end

end
