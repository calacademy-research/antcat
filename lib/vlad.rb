# coding: UTF-8
class Vlad

  def Vlad.idate show_progress = false
    Progress.new_init show_progress: show_progress
    Progress.puts
    Statistic.descendants.each &:display
    Problem.descendants.each &:display
  end

  ###########
  class Report
    def self.display_result_count count
      return if count.zero?
      display_section_header count
    end
    def self.display_results_section results, options = {}
      return unless results.present?
      options = options.reverse_merge sort: true
      display_section_header results.count
      lines = results.map {|item| yield item}
      lines.sort! if options[:sort]
      lines.reverse! if options[:reverse_order]
      lines.each {|line| Progress.puts '  ' + line}
      display_section_header results.count if results.count > 100
    end
    def self.display_section_header count
      Progress.puts "#{self.name.demodulize.titleize.capitalize}: #{count}"
    end
  end

  class Problem < Report
  end

  class Statistic < Report
  end

  ###########
  class ProtonymsWithoutAuthorships < Problem
    def self.query
      Protonym.where authorship_id: nil
    end
    def self.display
      display_results_section query do |protonym|
        taxon = Taxon.where(protonym_id: protonym).first
        if taxon
          taxon.name.name
        else
          "Orphan protonym: " + protonym.name.name
        end
      end
    end
  end

  class TaxaWithoutProtonyms < Problem
    def self.query
      Taxon.where protonym_id: nil
    end
    def self.display
      display_results_section query do |taxon|
        taxon.name.name
      end
    end
  end

  class TaxaWithDeletedProtonyms < Problem
    def self.query
      Taxon.
        where('protonym_id IS NOT NULL').
        joins('LEFT OUTER JOIN protonyms ON protonym_id = protonyms.id').
        where('protonyms.id IS NULL')
    end
    def self.display
      display_results_section query do |taxon|
        taxon.name.name
      end
    end
  end

  class OrphanProtonyms < Problem
    def self.query
      Protonym.includes(:taxon).where('taxa.id IS NULL')
    end
    def self.display
      display_results_section query do |protonym|
        protonym.name.name
      end
    end
  end

  class DuplicateValids < Problem
    def self.query
     Taxon.select('names.name AS name, COUNT(names.name) AS count').
           with_names.
           group('names.name', :genus_id).
           where(status: 'valid').
           where(unresolved_homonym: false).
           having('COUNT(names.name) > 1').
           all.
           map {|row| {name: row['name'], count: row['count']}}
    end
    def self.display
      display_results_section query do |duplicate|
        "#{duplicate[:name]} #{duplicate[:count]}"
      end
    end
  end

  class NamesWithoutTaxa < Problem
    def self.query
      Name.find_by_sql(
        %{SELECT names.id FROM names } +
          %{LEFT OUTER JOIN taxa taxa_name_id      ON taxa_name_id.name_id = names.id } +
          %{LEFT OUTER JOIN taxa taxa_type_name_id ON taxa_type_name_id.type_name_id = names.id } +
          %{LEFT OUTER JOIN protonyms              ON protonyms.name_id = names.id } +
          %{WHERE } +
            %{taxa_name_id.id IS null AND } +
            %{taxa_type_name_id.id IS null AND } +
            %{protonyms.id IS null }
      ).map {|e| Name.find e['id']}
    end
    def self.display
      display_result_count query.size
    end
  end

  class SubspeciesWithoutSpecies < Problem
    def self.query
      Subspecies.where 'species_id IS NULL'
    end
    def self.display
      display_result_count query.size
      #display_results_section query do |subspecies|
        #subspecies.name.to_s
      #end
    end
  end

  class SynonymsWithoutSeniors < Problem
    def self.query
      Taxon.find_by_sql "SELECT taxa.id FROM taxa LEFT OUTER JOIN synonyms on taxa.id = synonyms.junior_synonym_id WHERE status = 'synonym' AND synonyms.id IS NULL"
    end
    def self.display
      display_results_section query do |taxon|
        Taxon.find(taxon).name.name
      end
    end
  end

  class DuplicateSynonyms < Problem
    def self.query
      Taxon.find_by_sql "SELECT junior_synonym_id FROM synonyms GROUP by senior_synonym_id, junior_synonym_id HAVING COUNT(*) > 1"
    end
    def self.display
      display_result_count query.size
    end
  end

  class DuplicateNames < Problem
    def self.query
      Name.duplicates
    end
    def self.display
      display_result_count query.size
    end
  end

  class AuthorsWithoutNames < Problem
    def self.query
      Author.find_by_sql "SELECT authors.id FROM authors LEFT OUTER JOIN author_names on authors.id = author_names.author_id WHERE author_names.id IS NULL"
    end
    def self.display
      display_result_count query.size
    end
  end

  class GeneraWithTribesButNotSubfamilies < Problem
    def self.query
      Genus.where "tribe_id IS NOT NULL AND subfamily_id IS NULL"
    end
    def self.display
      display_results_section query do |genus|
        "#{genus.name} (tribe #{genus.tribe.name})"
      end
    end
  end

  class TaxaWithMismatchedHomonymAndStatus #< Problem
    def self.query
      Taxon.where "(status = 'homonym') = (homonym_replaced_by_id IS NULL)"
    end
    def self.display
      display_results_section query do |taxon|
        "#{taxon.name} (#{taxon.status}) #{taxon.homonym_replaced_by_id}"
      end
    end
  end

  class SynonymCycles < Problem
    def self.query
      Taxon.find_by_sql('
        SELECT a.senior_synonym_id AS taxon_a, a.junior_synonym_id AS taxon_b
        FROM synonyms a JOIN synonyms b ON
          a.senior_synonym_id = b.junior_synonym_id AND
          b.senior_synonym_id = a.junior_synonym_id
        WHERE a.id < b.id
        ORDER BY a.senior_synonym_id
      ').map do |row|
        [Taxon.find(row["taxon_a"]).name_cache,
         Taxon.find(row["taxon_b"]).name_cache]
      end
    end
    def self.display
      display_results_section query do |names|
        "#{names[0]}, #{names[1]}"
      end
    end
  end

  class TaxonCounts < Statistic
    def self.query
      Taxon.select('type, COUNT(*) AS count').group(:type).map do |result|
        [result['type'], result['count'].to_i]
      end
    end
    def self.display
      display_results_section query, sort: false do |count|
        "#{count.first.rjust(11)} #{count.second}"
      end
    end
  end

  class StatusCounts < Statistic
    def self.query
      Taxon.select('status, COUNT(*) AS count').group(:status).order('count DESC').map do |result|
        [result['status'], result['count'].to_i]
      end
    end
    def self.display
      display_results_section query, sort: false do |count|
        "#{count.first.rjust(21)} #{count.second}"
      end
    end
  end

  class RecordCounts < Statistic
    def self.query
      [ AuthorName,
        Author,
        Bolton::Match,
        Bolton::Reference,
        Citation,
        Journal,
        Name,
        Place,
        Protonym,
        Publisher,
        ReferenceAuthorName,
        ReferenceDocument,

        # UnmissingReference subclasses need to be loaded
        # for UnmissingReference.count to work
        Reference,
        ArticleReference,
        BookReference,
        NestedReference,
        UnknownReference,
        UnmissingReference,
        MissingReference,

        ForwardRef,
        Synonym,
        Taxon,
        TaxonHistoryItem,
        User,
      ].map do |table|
        {table: table.to_s, count: table.count}
      end
    end
    def self.display
      display_results_section query, sort: false do |result|
        "#{result[:count].to_s.rjust(7)} #{result[:table]}"
      end
    end
  end

  class ReferenceDocumentCounts < Statistic
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
  end

  class SynonymsWithoutCurrentValidTaxon < Problem
    def self.query
      Taxon.where(status: 'synonym').all.select do |synonym|
        synonym.current_valid_taxon.nil?
      end
    end
    def self.display
      display_result_count query.size
    end
  end

end
