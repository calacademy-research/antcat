require 'levenshtein'

class Antweb::Diff
  attr_reader :match_count, :difference_count, :differences, :antcat_unmatched_count, :antweb_unmatched_count,
              :antcat_unmatched

  def initialize show_progress = false
    Progress.init show_progress
    @match_count = @difference_count = @antcat_unmatched_count = @antweb_unmatched_count = 0
    @differences = []
    @antcat_unmatched = []
  end

  def diff_files antcat_directory, antweb_directory
    antcat_filename = "#{antcat_directory}/extant.xls"
    antweb_filename = "#{antweb_directory}/extant.xls.utf8"
    Progress.puts "Diffing #{antcat_filename} against #{antweb_filename}"
    diff File.open(antcat_filename, 'r').readlines, File.open(antweb_filename, 'r').readlines

    show_differences
    show_antcat_unmatched
    Progress.puts "#{@match_count} matches"
    Progress.puts "#{@difference_count} matches with differences"
    Progress.puts "#{@antcat_unmatched_count} antcat lines unmatched"
    Progress.puts "#{@antweb_unmatched_count} antweb lines unmatched"
  end

  def diff antcat, antweb
    self.class.preprocess_antweb antweb
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
          @antcat_unmatched << antcat_record
        else
          for antweb_record in antweb_records
            combinations << [antcat_record, antweb_record, self.class.closeness(antcat_record, antweb_record)]
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
        elsif combination[2] == 0
          @match_count += 1
        else
          @differences << [combination[0], combination[1]]
          @difference_count += 1
        end
      end
    end

    @antweb_unmatched_count = antweb.size - @match_count - @difference_count
  end

  def self.closeness antcat, antweb
    # AntWeb just got this one's taxonomic history wrong
    return 0 if antweb =~ /Martialinae\tLeptanillini\tMartialis\t\t\t\tTRUE\tTRUE\tMartialis\t/
    Levenshtein.distance(antcat, antweb)
  end

  def self.preprocess_antweb antweb
    for line in antweb

      # AntWeb parsed these correctly, but it was a typo in Bolton which in AntCat
      # was corrected manually
      line.gsub! /(Myrmicinae\tAttini\tPseudoatta\t\t\t\t)FALSE\tFALSE\t\t/i, "\\1TRUE\tTRUE\tPseudoatta\t"
      line.gsub! /(Amblyoponinae\t\tParaprionopelta\t\t\t\t)FALSE\tFALSE\t\t/i, "\\1TRUE\tTRUE\tParaprionopelta\t"
      line.gsub! /(Leptanilloidinae\t\tAsphinctanilloides\t\t\t\t)FALSE\tFALSE\t\t/i, "\\1TRUE\tTRUE\tAsphinctanilloides\t"
      line.gsub! /Myrmicinae\tincertae sedis in Stenammini\tPropodilobus/, "Myrmicinae\tStenammini\tPropodilobus"
      line.gsub! /Quinqueangulicapito/, 'Quineangulicapito'

      antweb_fields = line.split "\t"

      # AntWeb doesn't store the tribes of all genera
      if antweb_fields[1].blank? && antweb_fields[3].blank? && antweb_fields[2].present?
        genus = Genus.find_by_name antweb_fields[2]
        tribe = genus && genus.tribe && genus.tribe.name
        antweb_fields[1] = tribe
        line.replace antweb_fields.join("\t")
      end

    end
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
      Progress.puts "\n" + '=' * 80
      Progress.puts antcat[0..match_fails_at - 1]
      Progress.puts "<<< #{antcat[match_fails_at]} len: #{antcat.length}"
      Progress.puts antcat[match_fails_at..-1] || ''
      Progress.puts '==='
      Progress.puts antweb[match_fails_at..-1] || ''
      Progress.puts ">>> #{antweb[match_fails_at]} len: #{antweb.length}"
    end
  end

  def show_antcat_unmatched
    return
    return unless @antcat_unmatched.present?
    Progress.puts "antcat unmatched:"
    @antcat_unmatched.sort.each do |antcat|
      Progress.puts antcat.split("\t")[0,4].join("\t")
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
