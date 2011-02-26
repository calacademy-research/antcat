require 'levenshtein'

class Antweb::Diff
  attr_reader :match_count, :difference_count, :differences, :antcat_unmatched_count, :antweb_unmatched_count

  def initialize show_progress = false
    Progress.init show_progress
    @match_count = @difference_count = @antcat_unmatched_count = @antweb_unmatched_count = 0
    @differences = []
  end

  def diff_files antcat_directory, antweb_directory
    ['extant', 'extinct'].each do |filename|
      antcat_filename = "#{antcat_directory}/#{filename}.xls"
      antweb_filename = "#{antweb_directory}/#{filename}.xls.utf8"
      Progress.puts "Diffing #{antcat_filename} against #{antweb_filename}"
      diff File.open(antcat_filename, 'r').readlines, File.open(antweb_filename, 'r').readlines
    end
    show_differences
    Progress.puts "#{@match_count} matches"
    Progress.puts "#{@difference_count} matches with differences"
    Progress.puts "#{@antcat_unmatched_count} antcat lines unmatched"
    Progress.puts "#{@antweb_unmatched_count} antweb lines unmatched"
  end

  def diff antcat, antweb
    antcat.sort!
    antweb.sort!
    Progress.puts "#{antcat.size} antcat lines, #{antweb.size} antweb lines"

    antcat_taxa = make_taxa_groups antcat
    antweb_taxa = make_taxa_groups antweb

    antcat_taxa.each_key do |antcat_taxon|
      antcat_records = antcat_taxa[antcat_taxon]
      antweb_records = antweb_taxa[antcat_taxon]

      combinations = []
      for antcat_record in antcat_records
        unless antweb_records
          @antcat_unmatched_count += 1
        else
          for antweb_record in antweb_records
            combinations << [antcat_record, antweb_record, Levenshtein.distance(antcat_record, antweb_record)]
          end
        end
      end
      combinations = combinations.sort_by {|a| a[2]}
      for combination_index in 0...(combinations.size - 1)
        combination = combinations[combination_index]
        for other_combination_index in (combination_index + 1)...combinations.size
          other_combination = combinations[other_combination_index]
          if other_combination[0] == combination[0]
            other_combination[0] = nil
          end
          if other_combination[1] == combination[1]
            other_combination[1] = nil
          end
        end
      end
      combinations.each do |combination|
        if combination[0] != nil && combination[1] == nil
          @antcat_unmatched_count += 1
        elsif combination[0] == nil && combination[1] != nil
          @antweb_unmatched_count += 1
        elsif combination[0] == combination[1]
          @match_count += 1
        else
          @differences << [combination[0], combination[1]]
          @difference_count += 1
        end
      end
    end

    @antweb_unmatched_count = antweb.size - @match_count - @difference_count
  end

  def self.match_fails_at antcat, antweb
    index = 0
    while index < antcat.size && index < antweb.size
      return index if antcat[index] != antweb[index]   
      index += 1
    end
    antcat[index] == antweb[index] ? nil : index
  end

  private
  def make_taxa_groups records
    groups = {}
    records.each do |record|
      record = preprocess record
      key = get_key record
      groups[key] ||= []
      groups[key] << record
    end
    groups
  end

  def get_key record
    record.split("\t")[0, 4]
  end

  def show_differences
    return unless @differences.present?
    Progress.puts "Differences:"
    @differences.each do |antcat, antweb|
      match_fails_at = self.class.match_fails_at antcat, antweb
      Progress.puts "\nDiffer at #{match_fails_at}"
      Progress.puts antcat[0..match_fails_at - 1]
      Progress.puts "<<< #{antcat[match_fails_at]} len: #{antcat.length}"
      Progress.puts antcat[match_fails_at..-1] || ''
      Progress.puts '==='
      Progress.puts antweb[match_fails_at..-1] || ''
      Progress.puts ">>> #{antweb[match_fails_at]} len: #{antweb.length}"
    end
  end

  def preprocess line
    line = line.chomp
    line = line.gsub(/<.*?>/, ' ')
    line = line.gsub(/&nbsp;/, '')
    line = line.gsub(/\xC2\xA0/, '')
    line = line.gsub(/true/, 'TRUE')
    line = line.gsub(/false/, 'FALSE')
    line = line.squeeze(' ')
    line = line.rstrip
  end
end
