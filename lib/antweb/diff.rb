class Antweb::Diff
  attr_reader :match_count, :left_count, :right_count, :difference_count,
              :left_unmatched_count, :right_unmatched_count

  def initialize show_progress = false
    Progress.init show_progress
    @match_count = @left_count = @right_count = @difference_count = 
      @left_unmatched_count = @right_unmatched_count = 0
    @differences = []
  end

  def diff_files left_directory, right_directory
    left_filename = "#{left_directory}/extant.xls"
    right_filename = "#{right_directory}/extant.xls.utf8"
    Progress.puts "Diffing #{left_filename} against #{right_filename}"
    diff File.open(left_filename, 'r').readlines, File.open(right_filename, 'r').readlines
  end

  def diff left, right
    left.sort!
    right.sort!
    @left_count = left.size
    @right_count = right.size
    Progress.puts "#{@left_count} lines vs. #{right_count} lines"

    left_index = right_index = 0
    while left_index < left.size && right_index < right.size
      result = compare left[left_index], right[right_index]
      if result == 0
        left_index += 1
        right_index += 1
      elsif result == 1
        @right_unmatched_count += 1
        right_index += 1
      else
        @left_unmatched_count += 1
        left_index += 1
      end
    end

    @left_unmatched_count += left.size - left_index
    @right_unmatched_count += right.size - right_index

    show_differences
    Progress.puts "#{@match_count} matched"
    Progress.puts "#{@difference_count} matched with differences"
    Progress.puts "#{@left_unmatched_count} unmatched on left"
    Progress.puts "#{@right_unmatched_count} unmatched on right"
  end

  def self.match_fails_at left, right
    index = 0
    while index < left.size && index < right.size
      return index if left[index] != right[index]   
      index += 1
    end
    left[index] == right[index] ? nil : index
  end

  def self.format_failed_match string, failed_at
    string = string.dup
    if failed_at < string.size
      string.insert failed_at + 1, '<<<'
    else
      string << '[substring]'
    end
  end

  private
  def show_differences
    Progress.puts "Differences:"
    @differences.each do |left, right|
      match_fails_at = self.class.match_fails_at left, right
      Progress.puts "\nDiffer at #{match_fails_at}"
      Progress.puts left[0..match_fails_at - 1]
      Progress.puts "<<< #{left[match_fails_at]} len: #{left.length}"
      Progress.puts left[match_fails_at..-1] || ''
      Progress.puts "#{left[-3]}, #{left[-2]}, #{left[-1]}"
      Progress.puts '==='
      Progress.puts right[match_fails_at..-1] || ''
      Progress.puts ">>> #{right[match_fails_at]} len: #{right.length}"
      Progress.puts "#{right[-3]}, #{right[-2]}, #{right[-1]}"
    end
  end

  def show_difference string, match_fails_at
    Progress.puts self.class.format_failed_match string, match_fails_at
  end

  def compare left, right
    left = preprocess left
    right = preprocess right
    result = left <=> right
    if compare_prefixes(left, right) == 0
      if result == 0
        @match_count += 1
      else
        @difference_count += 1
        @differences << [left, right]
      end
      return 0
    end
    result
  end

  def compare_prefixes left, right
    left = left.split "\t"
    right = right.split "\t"
    left[0] <=> right[0]
  end

  def preprocess line
    line.chomp.gsub(/<.*?>/, ' ').gsub(/&nbsp;/, '').gsub(/\xC2\xA0/, '').squeeze(' ').rstrip
  end
end
