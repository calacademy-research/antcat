class Antweb::Diff
  attr_reader :match_count, :left_count, :right_count, :difference_count

  def initialize show_progress = false
    @match_count = @left_count = @right_count = @difference_count = 0
  end

  def diff_files left, right
    diff File.open(left, 'r').readlines, File.open(right, 'r').readlines
  end

  def diff left, right
    left.sort!
    right.sort!
    @left_count = left.size
    @right_count = right.size

    left_index = right_index = 0
    while left_index < left.size && right_index < right.size
      result = compare left[left_index], right[right_index]
      if result == 0
        left_index += 1
        right_index += 1
      elsif result == 1
        right_index += 1
      else
        left_index += 1
      end
    end
  end

  private
  def compare left, right
    result = left <=> right
    if compare_prefixes(left, right) == 0
      if result == 0
        @match_count += 1
      else
        @difference_count += 1
      end
    end
    result
  end

  def compare_prefixes left, right
    left = left.split "\t"
    right = right.split "\t"
    left[0] <=> right[0]
  end
end
