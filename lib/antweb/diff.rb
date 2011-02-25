class Antweb::Diff
  attr_reader :match_count, :difference_count, :antcat_unmatched_count, :antweb_unmatched_count

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

    antcat_index = antweb_index = 0
    while antcat_index < antcat.size && antweb_index < antweb.size
      result = compare antcat[antcat_index], antweb[antweb_index]
      if result == 0
        antcat_index += 1
        antweb_index += 1
      elsif result == 1
        @antweb_unmatched_count += 1
        antweb_index += 1
      else
        @antcat_unmatched_count += 1
        antcat_index += 1
      end
    end

    @antcat_unmatched_count += antcat.size - antcat_index
    @antweb_unmatched_count += antweb.size - antweb_index
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

  def compare antcat, antweb
    antcat = preprocess antcat
    antweb = preprocess antweb
    result = antcat <=> antweb
    if compare_prefixes(antcat, antweb) == 0
      if result == 0
        @match_count += 1
      else
        @difference_count += 1
        @differences << [antcat, antweb]
      end
      return 0
    end
    result
  end

  def compare_prefixes antcat, antweb
    antcat = antcat.split "\t"
    antweb = antweb.split "\t"
    antcat[0] <=> antweb[0]
  end

  def preprocess line
    line.chomp.gsub(/<.*?>/, ' ').gsub(/&nbsp;/, '').gsub(/\xC2\xA0/, '').squeeze(' ').rstrip
  end
end
