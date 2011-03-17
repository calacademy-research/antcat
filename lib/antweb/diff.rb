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
    preprocess_antweb antweb
    Progress.puts "#{antcat.size} antcat lines, #{antweb.size} antweb lines"

    antcat.sort!
    antweb.sort!

    antcat_taxon_groups = make_taxon_groups antcat
    antweb_taxon_groups = make_taxon_groups antweb

    antcat_taxon_groups.each_key do |antcat_taxon|
      compare_taxon_group antcat_taxon_groups[antcat_taxon], antweb_taxon_groups[antcat_taxon]
    end

    @antweb_unmatched_count = antweb.size - @match_count - @difference_count
  end

  def compare_taxon_group antcat_taxon_group, antweb_taxon_group
    pairs = compare_each_pair(antcat_taxon_group, antweb_taxon_group).sort_by {|a| a[2]}
    set_duplicates_to_nil pairs if pairs.present?
    tally_pairs pairs
  end

  def compare_each_pair antcat_taxon_group, antweb_taxon_group
    pairs = []
    for antcat_record in antcat_taxon_group
      if antweb_taxon_group
        for antweb_record in antweb_taxon_group
          pairs << [antcat_record, antweb_record, closeness(antcat_record, antweb_record)]
        end
      else
        @antcat_unmatched_count += 1
        @antcat_unmatched << antcat_record
      end
    end
    pairs
  end

  def set_duplicates_to_nil pairs
    pairs[0, pairs.size - 1].each_with_index do |pair, i|
      pairs[(i + 1)...pairs.size].each do |other_pair|
        other_pair[0] = nil if other_pair[0] == pair[0]
        other_pair[1] = nil if other_pair[1] == pair[1]
      end
    end
    pairs
  end

  def tally_pairs pairs
    pairs.each do |pair|
      if pair[0] != nil && pair[1] == nil
        @antcat_unmatched_count += 1
      elsif pair[0] == nil && pair[1] != nil
        @antweb_unmatched_count += 1
      elsif pair[2] == 0
        @match_count += 1
      else
        @differences << [pair[0], pair[1]]
        @difference_count += 1
      end
    end
  end

  def closeness antcat, antweb
    # AntWeb just got this one's taxonomic history wrong
    return 0 if antweb =~ /Martialinae\tLeptanillini\tMartialis\t\t\t\tTRUE\tTRUE\tMartialis\t/
    return 0 if match_with_acceptable_taxonomic_history_difference antcat, antweb
    Levenshtein.distance(antcat, antweb)
  end

  def match_with_acceptable_taxonomic_history_difference antcat, antweb
    antcat = antcat.split "\t"
    antweb = antweb.split "\t"
    return unless antcat[0,9] == antweb[0,9]
    antcat_taxonomic_history = antcat[10]
    antweb_taxonomic_history = antweb[10]
    return true if antcat_taxonomic_history.try(:downcase) == antweb_taxonomic_history.try(:downcase)
    return unless antcat_taxonomic_history.split(' ')[0].downcase == antweb_taxonomic_history.split(' ')[0].downcase
    return unless antweb_taxonomic_history =~ /\w+ \[junior (synonym|homonym)/
    true
  end

  def preprocess_antweb antweb
    for line in antweb

      # AntWeb parsed these correctly, but it was a typo in Bolton which in AntCat
      # was corrected manually
      line.gsub! /(Myrmicinae\tAttini\tPseudoatta\t\t\t\t)FALSE\tFALSE\t\t/i, "\\1TRUE\tTRUE\tPseudoatta\t"
      line.gsub! /(Amblyoponinae\t\tParaprionopelta\t\t\t\t)FALSE\tFALSE\t\t/i, "\\1TRUE\tTRUE\tParaprionopelta\t"
      line.gsub! /(Leptanilloidinae\t\tAsphinctanilloides\t\t\t\t)FALSE\tFALSE\t\t/i, "\\1TRUE\tTRUE\tAsphinctanilloides\t"
      line.gsub! /Myrmicinae\tincertae sedis in Stenammini\tPropodilobus/, "Myrmicinae\tStenammini\tPropodilobus"
      line.gsub! /Quinqueangulicapito/, 'Quineangulicapito'
      line.gsub! /syonym/, 'synonym'

      antweb_fields = line.split "\t"

      # AntWeb doesn't store the tribes of all genera
      if antweb_fields[1].blank? && antweb_fields[3].blank? && antweb_fields[2].present?
        genus = Genus.find_by_name antweb_fields[2]
        tribe = genus && genus.tribe && genus.tribe.name
        antweb_fields[1] = tribe
      end

      # The species author date and country columns appear bogus and unused
      antweb_fields[4] = antweb_fields[5] = nil

      line.replace antweb_fields.join("\t")

    end
  end

  def match_fails_at antcat, antweb
    index = 0
    while index < antcat.size && index < antweb.size
      return index if antcat[index] != antweb[index]   
      index += 1
    end
    antcat[index] == antweb[index] ? nil : index
  end

  private
  def make_taxon_groups records
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
      next unless antcat && antweb
      match_fails_at = match_fails_at antcat, antweb
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
